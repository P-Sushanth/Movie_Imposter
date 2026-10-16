import React, { useState, useEffect, useCallback } from "react";
import { StyleSheet, BackHandler, Alert, View } from "react-native";
import { StatusBar } from "expo-status-bar";
import { SafeAreaProvider, SafeAreaView } from "react-native-safe-area-context";

import { colors } from "./src/theme";
import { Industry } from "./src/data/movies/types";
import { ALL_MOVIES } from "./src/data/movies";
import { RoundState } from "./src/domain/types";
import { createRound } from "./src/domain/gameSetup";

import { SetupScreen } from "./src/screens/SetupScreen";
import { DealCardsScreen } from "./src/screens/DealCardsScreen";
import { DiscussionScreen } from "./src/screens/DiscussionScreen";

type ScreenName = "setup" | "dealing" | "discussion";

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<ScreenName>("setup");

  // Selection states
  const [selectedIndustries, setSelectedIndustries] = useState<Industry[]>([
    "tollywood",
    "bollywood",
    "hollywood",
  ]);
  const [players, setPlayers] = useState<string[]>(["", "", ""]);
  const [numImposters, setNumImposters] = useState<number>(1);
  const [imposterClueEnabled, setImposterClueEnabled] = useState<boolean>(true);

  // Active round state
  const [roundState, setRoundState] = useState<RoundState | null>(null);

  // Industry handlers
  const handleToggleIndustry = (ind: Industry) => {
    setSelectedIndustries((prev) => {
      if (prev.includes(ind)) {
        return prev.filter((i) => i !== ind);
      } else {
        return [...prev, ind];
      }
    });
  };

  const handleSelectAllIndustries = () => {
    setSelectedIndustries(["tollywood", "bollywood", "hollywood"]);
  };

  // Player handlers
  const handleChangePlayer = (index: number, name: string) => {
    setPlayers((prev) => {
      const copy = [...prev];
      copy[index] = name;
      return copy;
    });
  };

  const handleAddPlayer = () => {
    if (players.length < 10) {
      setPlayers((prev) => [...prev, ""]);
    }
  };

  const handleRemovePlayer = (index: number) => {
    if (players.length > 3) {
      setPlayers((prev) => prev.filter((_, i) => i !== index));
      // Adjust numImposters if needed
      setNumImposters((curr) => Math.max(1, Math.min(curr, Math.floor((players.length - 1) / 2))));
    }
  };

  // Track movies played in this session only
  const [usedMovieIds, setUsedMovieIds] = useState<Set<string>>(new Set());

  // Start Game handler
  const handleStartGame = () => {
    try {
      const newRound = createRound({
        players,
        selectedIndustries,
        moviePool: ALL_MOVIES,
        numImposters,
        imposterClueEnabled,
        previousMovieId: roundState?.movieId,
        usedMovieIds,
      });
      setUsedMovieIds((prev) => new Set(prev).add(newRound.movieId));
      setRoundState(newRound);
      setCurrentScreen("dealing");
    } catch (err: any) {
      Alert.alert("Cannot Start Round", err.message || "An error occurred.");
    }
  };

  // Card dealing handlers
  const handleNextPlayerCard = () => {
    if (roundState) {
      setRoundState({
        ...roundState,
        currentCardIndex: roundState.currentCardIndex + 1,
      });
    }
  };

  const handleFinishDealing = () => {
    if (roundState) {
      const shuffled = [...roundState.players].sort(() => Math.random() - 0.5);
      setRoundState({
        ...roundState,
        startingPlayer: shuffled[0],
        discussionOrder: shuffled,
        phase: "discussion",
      });
      setCurrentScreen("discussion");
    }
  };

  // Return to Setup handler
  const handleReturnToSetup = () => {
    setRoundState(null);
    setCurrentScreen("setup");
  };

  // Android Back Button safety
  const handleHardwareBack = useCallback(() => {
    if (currentScreen === "setup") {
      return false; // Exit app
    }
    if (currentScreen === "dealing") {
      Alert.alert(
        "Exit Current Round?",
        "Going back will cancel the round in progress.",
        [
          { text: "Continue Playing", style: "cancel" },
          {
            text: "Exit Round",
            style: "destructive",
            onPress: () => {
              setRoundState(null);
              setCurrentScreen("setup");
            },
          },
        ]
      );
      return true;
    }
    if (currentScreen === "discussion") {
      setCurrentScreen("setup");
      return true;
    }
    return false;
  }, [currentScreen]);

  useEffect(() => {
    const backSubscription = BackHandler.addEventListener(
      "hardwareBackPress",
      handleHardwareBack
    );
    return () => backSubscription.remove();
  }, [handleHardwareBack]);

  return (
    <SafeAreaProvider>
      <SafeAreaView style={styles.safeArea}>
        <StatusBar style="dark" />
        <View style={styles.container}>
          {currentScreen === "setup" && (
            <SetupScreen
              selectedIndustries={selectedIndustries}
              onToggleIndustry={handleToggleIndustry}
              onSelectAllIndustries={handleSelectAllIndustries}
              players={players}
              onChangePlayer={handleChangePlayer}
              onAddPlayer={handleAddPlayer}
              onRemovePlayer={handleRemovePlayer}
              numImposters={numImposters}
              onChangeNumImposters={setNumImposters}
              imposterClueEnabled={imposterClueEnabled}
              onToggleClueEnabled={setImposterClueEnabled}
              onStartGame={handleStartGame}
            />
          )}

          {currentScreen === "dealing" && roundState && (
            <DealCardsScreen
              assignments={roundState.assignments}
              currentCardIndex={roundState.currentCardIndex}
              onNextPlayer={handleNextPlayerCard}
              onFinishDealing={handleFinishDealing}
            />
          )}

          {currentScreen === "discussion" && roundState && (
            <DiscussionScreen
              movieTitle={roundState.movieTitle}
              imposters={roundState.imposters}
              startingPlayer={roundState.startingPlayer}
              discussionOrder={roundState.discussionOrder}
              onReturnToSetup={handleReturnToSetup}
            />
          )}
        </View>
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
});
