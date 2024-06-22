"use client";

import React, { Suspense, useEffect, useState } from "react";
import "./globals.css";
import { GlobalContext, PHProvider, PostHogPageview } from "./providers";
import { Header } from "@/components/header";
import { encode, decode } from "@/lib/utils";

export const defaultSource = `title 'Shadow Priest WhackAura'
load spec: :shadow_priest
hide_ooc!

dynamic_group 'WhackAuras' do
  debuff_missing 'Shadow Word: Pain'
end`;

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const hash = typeof window !== "undefined" ? window.location.hash : "";
  const [source, setSource] = useState<string>(defaultSource);

  useEffect(() => {
    if (!source || source === "" || source === defaultSource) return;
    const base64 = encode(source);
    if (window?.location) window.location.hash = base64;
    history.pushState(null, "", `#${base64}`);
  }, [source]);

  useEffect(() => {
    const handleHashChange = () => {
      if (!window?.location?.hash) return;
      setSource(decode(window?.location?.hash));
    };
    window.addEventListener("hashchange", handleHashChange);
    if (window?.location?.hash) handleHashChange();
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
