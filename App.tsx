import React, { useState, useEffect, useCallback } from "react";
import { StyleSheet, BackHandler, Alert, View } from "react-native";
import { StatusBar } from "expo-status-bar";
import { SafeAreaProvider, SafeAreaView } from "react-native-safe-area-context";

import { colors } from "./src/theme";
import { Industry } from "./src/data/movies/types";
import { ALL_MOVIES } from "./src/data/movies";
import { RoundState, PlayerGroup } from "./src/domain/types";
import { createRound, createNextRound } from "./src/domain/gameSetup";
import { resolvePlayerNames } from "./src/domain/validation";
import { groupService } from "./src/services/groupService";
import { movieHistoryService } from "./src/services/movieHistoryService";

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
  const [savedGroups, setSavedGroups] = useState<PlayerGroup[]>([]);
  const [selectedGroupId, setSelectedGroupId] = useState<string | null>(null);
  const [numImposters, setNumImposters] = useState<number>(1);
  const [imposterClueEnabled, setImposterClueEnabled] = useState<boolean>(true);
  const [revealNameToImposter, setRevealNameToImposter] = useState<boolean>(false);
  const [discussionTimerMinutes, setDiscussionTimerMinutes] = useState<number>(0);

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

  const handleMovePlayer = (fromIndex: number, toIndex: number) => {
    if (fromIndex >= 0 && fromIndex < players.length && toIndex >= 0 && toIndex < players.length) {
      setPlayers((prev) => {
        const copy = [...prev];
        const [moved] = copy.splice(fromIndex, 1);
        copy.splice(toIndex, 0, moved);
        return copy;
      });
    }
  };

  // Group handlers & lifecycle
  useEffect(() => {
    const loadGroups = async () => {
      const groups = await groupService.loadGroups();
      const lastId = await groupService.loadLastSelectedGroupId();
      setSavedGroups(groups);
      if (lastId && groups.some((g) => g.id === lastId)) {
        setSelectedGroupId(lastId);
        const group = groups.find((g) => g.id === lastId)!;
        setPlayers([...group.players]);
        setNumImposters((curr) => Math.max(1, Math.min(curr, Math.floor(group.players.length / 2))));
      }
    };
    loadGroups();

    // Load persistent cached used movies across sessions
    const loadCachedMovies = async () => {
      const cached = await movieHistoryService.loadUsedMovieIds();
      if (cached.length > 0) {
        setUsedMovieIds(new Set(cached));
      }
    };
    loadCachedMovies();
  }, []);

  const handleSelectGroup = (group: PlayerGroup) => {
    setSelectedGroupId(group.id);
    setPlayers([...group.players]);
    setNumImposters((curr) => Math.max(1, Math.min(curr, Math.floor(group.players.length / 2))));
    groupService.saveLastSelectedGroupId(group.id);
  };

  const handleCreateGroup = async (name: string) => {
    const valid = resolvePlayerNames(players);
    const newGroup = await groupService.createGroup(name, valid);
    const groups = await groupService.loadGroups();
    setSavedGroups(groups);
    setSelectedGroupId(newGroup.id);
  };

  const handleRenameGroup = async (groupId: string, newName: string) => {
    await groupService.renameGroup(groupId, newName);
    const groups = await groupService.loadGroups();
    setSavedGroups(groups);
  };

  const handleUpdateGroup = async (updated: PlayerGroup) => {
    const valid = resolvePlayerNames(players);
    await groupService.updateGroup({ ...updated, players: valid });
    const groups = await groupService.loadGroups();
    setSavedGroups(groups);
  };

  const handleDeleteGroup = async (groupId: string) => {
    await groupService.deleteGroup(groupId);
    const groups = await groupService.loadGroups();
    setSavedGroups(groups);
    if (selectedGroupId === groupId) {
      setSelectedGroupId(null);
    }
  };

  const handleClearGroup = () => {
    setSelectedGroupId(null);
    groupService.saveLastSelectedGroupId(null);
  };

  // Track movies played across sessions (backed by local storage cache)
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
        revealNameToImposter,
        discussionTimerMinutes,
        previousMovieId: roundState?.movieId,
        previousImposters: roundState?.imposters,
        usedMovieIds,
      });
      // Update in-memory set and persist to device cache
      const updatedSet = new Set(usedMovieIds).add(newRound.movieId);
      setUsedMovieIds(updatedSet);
      movieHistoryService.recordUsedMovieId(newRound.movieId);

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
      // Pick a random starting player, and maintain the circular seating order around the room
      const currentPlayers = roundState.players;
      const startIdx = Math.floor(Math.random() * currentPlayers.length);
      const circularOrder = currentPlayers.map(
        (_, i) => currentPlayers[(startIdx + i) % currentPlayers.length]
      );
      setRoundState({
        ...roundState,
        startingPlayer: circularOrder[0],
        discussionOrder: circularOrder,
        phase: "discussion",
      });
      setCurrentScreen("discussion");
    }
  };

  // Next Round handler (restarts card dealing with new movie from selected categories and same imposter)
  const handleNextRound = () => {
    if (roundState) {
      try {
        const nextRound = createNextRound({
          currentRound: roundState,
          moviePool: ALL_MOVIES,
          usedMovieIds,
        });
        const updatedSet = new Set(usedMovieIds).add(nextRound.movieId);
        setUsedMovieIds(updatedSet);
        movieHistoryService.recordUsedMovieId(nextRound.movieId);

        setRoundState(nextRound);
        setCurrentScreen("dealing");
      } catch (e) {
        Alert.alert("Error", "Could not generate next round movie.");
      }
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
              savedGroups={savedGroups}
              selectedGroupId={selectedGroupId}
              onSelectGroup={handleSelectGroup}
              onCreateGroup={handleCreateGroup}
              onRenameGroup={handleRenameGroup}
              onUpdateGroup={handleUpdateGroup}
              onDeleteGroup={handleDeleteGroup}
              onClearGroup={handleClearGroup}
              onChangePlayer={handleChangePlayer}
              onAddPlayer={handleAddPlayer}
              onRemovePlayer={handleRemovePlayer}
              onMovePlayer={handleMovePlayer}
              numImposters={numImposters}
              onChangeNumImposters={setNumImposters}
              imposterClueEnabled={imposterClueEnabled}
              onToggleClueEnabled={setImposterClueEnabled}
              revealNameToImposter={revealNameToImposter}
              onToggleRevealNameToImposter={setRevealNameToImposter}
              discussionTimerMinutes={discussionTimerMinutes}
              onChangeDiscussionTimer={setDiscussionTimerMinutes}
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
              discussionTimerMinutes={roundState.discussionTimerMinutes}
              onReturnToSetup={handleReturnToSetup}
              onNextRound={handleNextRound}
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
