import React from "react";
import {
  Pressable,
  Text,
  StyleSheet,
  ViewStyle,
  TextStyle,
  ActivityIndicator,
} from "react-native";
import { colors, borderRadius, spacing, typography } from "../theme";

interface PrimaryButtonProps {
  title: string;
  onPress: () => void;
  variant?: "primary" | "secondary" | "danger" | "outline";
  disabled?: boolean;
  loading?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
  icon?: React.ReactNode;
}

export const PrimaryButton: React.FC<PrimaryButtonProps> = ({
  title,
  onPress,
  variant = "primary",
  disabled = false,
  loading = false,
  style,
  textStyle,
  icon,
}) => {
  const getBackgroundColor = (pressed: boolean) => {
    if (disabled) return "#E2E8F0";
    if (variant === "primary") {
      return pressed ? colors.primaryLight : colors.primary;
    }
    if (variant === "secondary") {
      return pressed ? "#E2E8F0" : colors.surfaceElevated;
    }
    if (variant === "danger") {
      return pressed ? "#B91C1C" : colors.imposterRed;
    }
    if (variant === "outline") {
      return pressed ? "#F1F5F9" : "transparent";
    }
    return colors.primary;
  };

  const getTextColor = () => {
    if (disabled) return colors.textMuted;
    if (variant === "primary") return colors.textOnPrimary;
    if (variant === "secondary") return colors.textPrimary;
    if (variant === "danger") return colors.textOnPrimary;
    if (variant === "outline") return colors.textPrimary;
    return colors.textOnPrimary;
  };

  const getBorderColor = () => {
    if (disabled) return "#E2E8F0";
    if (variant === "outline") return colors.surfaceBorderDark;
    if (variant === "secondary") return colors.surfaceBorder;
    return "transparent";
  };

  return (
    <Pressable
      onPress={onPress}
      disabled={disabled || loading}
      style={({ pressed }) => [
        styles.button,
        {
          backgroundColor: getBackgroundColor(pressed),
          borderColor: getBorderColor(),
        },
        style,
      ]}
      accessibilityRole="button"
      accessibilityState={{ disabled: disabled || loading }}
    >
      {loading ? (
        <ActivityIndicator
          color={variant === "primary" ? colors.textOnPrimary : colors.primary}
        />
      ) : (
        <>
          {icon}
          <Text
            style={[
              styles.text,
              { color: getTextColor(), marginLeft: icon ? spacing.sm : 0 },
              textStyle,
            ]}
          >
            {title}
          </Text>
        </>
      )}
    </Pressable>
  );
};

const styles = StyleSheet.create({
  button: {
    height: 52,
    borderRadius: borderRadius.md,
    paddingHorizontal: spacing.xl,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    minWidth: 120,
  },
  text: {
    ...typography.button,
  },
});
