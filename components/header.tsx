"use client";

import * as pako from "pako";
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  navigationMenuTriggerStyle,
} from "@/components/ui/navigation-menu";
import { Share } from "lucide-react";
import Link from "next/link";
import { useContext, useEffect } from "react";
import { GlobalContext } from "../app/layout";

export function Header() {
  const { source, setSource } = useContext(GlobalContext);

  useEffect(() => {
    const input = new TextEncoder().encode(source);
    const output = pako.deflate(input);
    const base64 = Buffer.from(output, "binary").toString("base64");
    window.location.hash = base64;
    history.pushState(null, "", `#${base64}`);
  }, [source]);

  useEffect(() => {
    const handleHashChange = () => {
      const input = Buffer.from(window.location.hash, "base64");
      const output = pako.inflate(input);
      setSource(new TextDecoder().decode(output));
    };
    window.addEventListener("hashchange", handleHashChange);
    return () => {
      window.removeEventListener("hashchange", handleHashChange);
    };
  }, []);

  return (
    <header className="dark text-white sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 mb-4 p-2">
      <div className="container flex items-baseline">
        <h1 className="scroll-m-20 text-xl font-extrabold tracking-tight lg:text-xl pr-5">
          WeakAuras
        </h1>

        <NavigationMenu>
          <NavigationMenuList>
            <NavigationMenuItem>
              <Link href="/docs" legacyBehavior passHref>
                <NavigationMenuLink className={navigationMenuTriggerStyle()}>
                  <Share size={12} className="mr-2" /> Share
                </NavigationMenuLink>
              </Link>
            </NavigationMenuItem>
          </NavigationMenuList>
        </NavigationMenu>
      </div>
    </header>
  );
}
