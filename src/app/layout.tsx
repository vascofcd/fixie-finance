import { type ReactNode } from "react";
import type { Metadata } from "next";
import { Providers } from "./providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "fixie.finance",
  description: "Swapping fixed and floating interest rates",
};

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <head></head>
      <body>
        <Providers>{props.children}</Providers>
      </body>
    </html>
  );
}
