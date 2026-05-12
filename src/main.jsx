import React from "react";
import { createRoot } from "react-dom/client";
import TamboShell from "./TamboShell.jsx";
import { make as App } from "./App.bs.js";
import "./app.css";

createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <TamboShell>
      <App />
    </TamboShell>
  </React.StrictMode>
);
