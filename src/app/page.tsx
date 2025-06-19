"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import DashboardPage from "./dashboard";

export default function Home() {
  return (
    <div>
      <main>
        <ConnectButton />
        <DashboardPage />
      </main>
      <footer>This is a footer</footer>
    </div>
  );
}
