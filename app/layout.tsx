import React from "react";
import "./globals.css";
import { cn } from "@/lib/utils";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={cn("min-h-screen bg-background font-sans antialiased")}>
        <div className="flex-1">{children}</div>
      </body>
    </html>
  );
}
