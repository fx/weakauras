import React, { Suspense } from "react";
import "./globals.css";
import { cn } from "@/lib/utils";
import posthog from "posthog-js";
import { PostHogProvider } from "posthog-js/react";
import { PHProvider, PostHogPageview } from "./providers";

if (typeof window !== "undefined") {
  posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY, {
    api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
  });
}

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
        <body
          className={cn("min-h-screen bg-background font-sans antialiased")}
        >
          <div className="flex-1">{children}</div>
        </body>
      </PHProvider>
    </html>
  );
}
