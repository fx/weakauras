"use client";

import React, { Suspense, createContext, useState } from "react";
import "./globals.css";
import posthog from "posthog-js";
import { PHProvider, PostHogPageview } from "./providers";
import { Header } from "@/components/header";

if (typeof window !== "undefined") {
  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
  });
}

type GlobalContextType = {
  setSource: (source: string) => void;
  source: string;
};

export const GlobalContext = createContext<GlobalContextType>({
  source: "",
  setSource: () => {},
});

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [source, setSource] = useState<string>(
    `title 'Shadow Priest WhackAura'
load spec: :shadow_priest
hide_ooc!

dynamic_group 'WhackAuras' do
  debuff_missing 'Shadow Word: Pain'
end`
  );

  return (
    <html lang="en">
      <Suspense>
        <PostHogPageview />
      </Suspense>
      <PHProvider>
        <GlobalContext.Provider value={{ source, setSource }}>
          <body className={"min-h-screen bg-background font-sans antialiased"}>
            <Header />
            <section className="container grid flex-1 items-center gap-6">
              {children}
            </section>
          </body>
        </GlobalContext.Provider>
      </PHProvider>
    </html>
  );
}
