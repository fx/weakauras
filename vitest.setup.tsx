import React, { useState } from "react";
import { GlobalContext } from "./app/providers";
import { defaultSource } from "./components/weak-aura-editor";

export const wrapper = ({ children }) => {
  const [source, setSource] = useState<string>(defaultSource);
  return (
    <>
      <GlobalContext.Provider value={{ source, setSource }}>
        {children}
      </GlobalContext.Provider>
    </>
  );
};
