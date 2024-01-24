"use client";

import React, { Suspense, createContext, useEffect, useState } from "react";
import "./globals.css";
import posthog from "posthog-js";
import { PHProvider, PostHogPageview } from "./providers";
import { Header } from "@/components/header";
import * as pako from "pako";

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

const encode = (source: string) => {
  const input = new TextEncoder().encode(source);
  const output = pako.deflate(input);
  return Buffer.from(output).toString("base64");
};

const decode = (hash: string) => {
  const input = Buffer.from(hash, "base64");
  const output = pako.inflate(input);
  return new TextDecoder().decode(output);
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [source, setSource] = useState<string>(
    window.location.hash
      ? decode(window.location.hash)
      : `title 'Shadow Priest WhackAura'
load spec: :shadow_priest
hide_ooc!

dynamic_group 'WhackAuras' do
  debuff_missing 'Shadow Word: Pain'
end`
  );

  useEffect(() => {
    const base64 = encode(source);
    window.location.hash = base64;
    history.pushState(null, "", `#${base64}`);
  }, [source]);

  useEffect(() => {
    const handleHashChange = () => {
      setSource(decode(window.location.hash));
    };
    window.addEventListener("hashchange", handleHashChange);
    return () => {
      window.removeEventListener("hashchange", handleHashChange);
    };
  }, []);

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
