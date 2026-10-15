import { Platform } from "react-native";

export const courierFont = Platform.select({
  ios: "Courier",
  android: "monospace",
  default: "Courier, monospace",
});

export const typography = {
  h1: {
    fontFamily: courierFont,
    fontSize: 28,
    fontWeight: "700" as const,
    lineHeight: 34,
  },
  h2: {
    fontFamily: courierFont,
    fontSize: 22,
    fontWeight: "700" as const,
    lineHeight: 28,
  },
  h3: {
    fontFamily: courierFont,
    fontSize: 18,
    fontWeight: "700" as const,
    lineHeight: 24,
  },
  bodyLarge: {
    fontFamily: courierFont,
    fontSize: 16,
    fontWeight: "400" as const,
    lineHeight: 22,
  },
  body: {
    fontFamily: courierFont,
    fontSize: 15,
    fontWeight: "400" as const,
    lineHeight: 20,
  },
  bodySmall: {
    fontFamily: courierFont,
    fontSize: 13,
    fontWeight: "400" as const,
    lineHeight: 18,
  },
  caption: {
    fontFamily: courierFont,
    fontSize: 12,
    fontWeight: "700" as const,
    lineHeight: 16,
    letterSpacing: 0.5,
    textTransform: "uppercase" as const,
  },
  button: {
    fontFamily: courierFont,
    fontSize: 15,
    fontWeight: "700" as const,
    letterSpacing: 0.5,
  },
};
