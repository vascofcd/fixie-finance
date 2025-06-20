"use client";

import { Header } from "@/components/layout/Header";
import DashboardPage from "./dashboard";

export default function Home() {
  return (
    <div>
      <header>
        <Header />
      </header>
      <main>
        <DashboardPage />
      </main>
      <footer>This is a footer</footer>
    </div>
  );
}
