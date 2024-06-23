"use client";

import { Header } from "@/components/header";
import { defaultSource } from "@/components/weak-aura-editor";
import React, { Suspense, useState } from "react";
import "./globals.css";
import { GlobalContext, PHProvider, PostHogPageview } from "./providers";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [source, setSource] = useState<string>(defaultSource);
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
