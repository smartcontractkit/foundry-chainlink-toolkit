package main

import (
	"encoding/hex"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/ethereum/go-ethereum/common"
	ocrConfigHelper "github.com/smartcontractkit/libocr/offchainreporting/confighelper"
	ocrTypes "github.com/smartcontractkit/libocr/offchainreporting/types"
)

type OffChainAggregatorConfig struct {
	DeltaProgress    time.Duration // The duration in which a leader must achieve progress or be replaced
	DeltaResend      time.Duration // The interval at which nodes resend NEWEPOCH messages
	DeltaRound       time.Duration // The duration after which a new round is started
	DeltaGrace       time.Duration // The duration of the grace period during which delayed oracles can still submit observations
	DeltaC           time.Duration // Limits how often updates are transmitted to the contract as long as the median isn’t changing by more than AlphaPPB
	AlphaPPB         uint64        // Allows larger changes of the median to be reported immediately, bypassing DeltaC
	DeltaStage       time.Duration // Used to stagger stages of the transmission protocol. Multiple Ethereum blocks must be mineable in this period
	RMax             uint8         // The maximum number of rounds in an epoch
	S                []int         // Transmission Schedule
	F                int           // The allowed number of "bad" oracles
	N                int           // The number of oracles
	OracleIdentities []ocrConfigHelper.OracleIdentityExtra
}

func main() {
	args := os.Args

	nodesArg := strings.Split(args[1], ",")
	nodes := make([]common.Address, len(nodesArg))
	for i, p := range nodesArg {
		n := common.HexToAddress(p)
		nodes[i] = n
	}

	offchainPublicKeys := strings.Split(args[2], ",")
	configPublicKeys := strings.Split(args[3], ",")
	onchainSigningAddresses := strings.Split(args[4], ",")
	peerIDs := strings.Split(args[5], ",")

	ocrConfig := DefaultOffChainAggregatorConfig(len(nodesArg) + 1) // including bootstrap node

	for i, transmitter := range nodes {
		var onChainSigningAddress [20]byte
		var configPublicKey [32]byte
		offchainSigningAddress, err := hex.DecodeString(offchainPublicKeys[i])
		if err != nil {
			panic(err)
		}
		decodeConfigKey, err := hex.DecodeString(configPublicKeys[i])
		if err != nil {
			panic(err)
		}

		copy(onChainSigningAddress[:], common.HexToAddress(onchainSigningAddresses[i]).Bytes())
		copy(configPublicKey[:], decodeConfigKey)

		oracleIdentity := ocrConfigHelper.OracleIdentity{
			TransmitAddress:       transmitter,            // address
			OnChainSigningAddress: onChainSigningAddress,  // addresss
			PeerID:                peerIDs[i],             // string
			OffchainPublicKey:     offchainSigningAddress, // []bytes
		}
		oracleIdentityExtra := ocrConfigHelper.OracleIdentityExtra{
			OracleIdentity:                  oracleIdentity,
			SharedSecretEncryptionPublicKey: ocrTypes.SharedSecretEncryptionPublicKey(configPublicKey), // [32]bytes
		}

		ocrConfig.OracleIdentities = append(ocrConfig.OracleIdentities, oracleIdentityExtra)
	}

	signers, transmitters, threshold, encodedConfigVersion, encodedConfig, _ := ocrConfigHelper.ContractSetConfigArgs(
		ocrConfig.DeltaProgress,
		ocrConfig.DeltaResend,
		ocrConfig.DeltaRound,
		ocrConfig.DeltaGrace,
		ocrConfig.DeltaC,
		ocrConfig.AlphaPPB,
		ocrConfig.DeltaStage,
		ocrConfig.RMax,
		ocrConfig.S,
		ocrConfig.OracleIdentities,
		ocrConfig.F,
	)

	signersStringArray := make([]string, len(signers))
	for i, signer := range signers {
		signersStringArray[i] = signer.String()
	}

	transmittersStringArray := make([]string, len(transmitters))
	for i, transmitter := range transmitters {
		transmittersStringArray[i] = transmitter.String()
	}

	hex.EncodeToString(encodedConfig)

	fmt.Println(
		"["+strings.Join(signersStringArray, ",")+"]",
		"["+strings.Join(transmittersStringArray, ",")+"]",
		threshold,
		encodedConfigVersion,
		hex.EncodeToString(encodedConfig))
}

func DefaultOffChainAggregatorConfig(numberNodes int) OffChainAggregatorConfig {
	if numberNodes <= 4 {
		panic("Insufficient number of nodes supplied for OCR, need at least 5")
	}
	s := []int{1}
	// First node's stage already inputted as a 1 in line above, so numberNodes-1.
	for i := 0; i < numberNodes-1; i++ {
		s = append(s, 2)
	}
	return OffChainAggregatorConfig{
		AlphaPPB:         1,
		DeltaC:           time.Minute * 60,
		DeltaGrace:       time.Second * 12,
		DeltaProgress:    time.Second * 35,
		DeltaStage:       time.Second * 60,
		DeltaResend:      time.Second * 17,
		DeltaRound:       time.Second * 30,
		RMax:             6,
		S:                s,
		N:                numberNodes,
		F:                1,
		OracleIdentities: []ocrConfigHelper.OracleIdentityExtra{},
	}
}
