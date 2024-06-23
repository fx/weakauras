"use client";

import { GlobalContext } from "@/app/providers";
import {
  Menubar,
  MenubarContent,
  MenubarItem,
  MenubarMenu,
  MenubarTrigger,
} from "@/components/ui/menubar";
import {
  NavigationMenu,
  NavigationMenuItem,
  NavigationMenuList,
} from "@/components/ui/navigation-menu";
import { Share } from "lucide-react";
import { useContext, useMemo } from "react";
import { useCopyToClipboard } from "usehooks-ts";
import assets from "../public/index.json";
import { Button } from "./ui/button";

export function Header() {
  const [_, copy] = useCopyToClipboard();
  const { source, setSource } = useContext(GlobalContext);

  const exampleItems = useMemo(
    () =>
      assets.examples.map((path) => {
        const frontMatter = assets.frontMatter[path];
        return (
          <MenubarItem
            key={path}
            onClick={async () => {
              const content = await (await fetch(path)).text();
              console.log(content, source);
              setSource(content);
            }}
          >
            {frontMatter?.title || path}
          </MenubarItem>
        );
      }),
    []
  );

  return (
    <header className="dark text-white sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 mb-4 p-2">
      <div className="container flex items-baseline">
        <h1 className="scroll-m-20 text-xl font-extrabold tracking-tight lg:text-xl pr-5">
          WeakAuras
        </h1>

        <Menubar>
          <MenubarMenu>
            <MenubarTrigger>Examples</MenubarTrigger>
            <MenubarContent>{exampleItems}</MenubarContent>
          </MenubarMenu>
        </Menubar>

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
