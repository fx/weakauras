"use client";

import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuList,
} from "@/components/ui/navigation-menu";
import { Share } from "lucide-react";
import { useCopyToClipboard } from "usehooks-ts";
import { Button } from "./ui/button";

export function Header() {
  const [_, copy] = useCopyToClipboard();

  return (
    <header className="dark text-white sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 mb-4 p-2">
      <div className="container flex items-baseline">
        <h1 className="scroll-m-20 text-xl font-extrabold tracking-tight lg:text-xl pr-5">
          WeakAuras
        </h1>

        <NavigationMenu>
          <NavigationMenuList>
            <NavigationMenuItem>
              <Button
                size="sm"
                onClick={(e) => {
                  e.preventDefault();
                  copy(window.location.href);
                }}
              >
                <Share size={12} className="mr-2" /> Share
              </Button>
            </NavigationMenuItem>
          </NavigationMenuList>
        </NavigationMenu>
      </div>
    </header>
  );
}
