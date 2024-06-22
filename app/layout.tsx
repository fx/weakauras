"use client";

import React, { Suspense, useEffect, useState } from "react";
import "./globals.css";
import { GlobalContext, PHProvider, PostHogPageview } from "./providers";
import { Header } from "@/components/header";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <Suspense>
        <PostHogPageview />
      </Suspense>
      <PHProvider>
        <body className={"min-h-screen bg-background font-sans antialiased"}>
          <Header />
          <section className="container grid flex-1 items-center gap-6">
            {children}
          </section>
        </body>
      </PHProvider>
    </html>
  );
}
