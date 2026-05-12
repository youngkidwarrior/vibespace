export function readFirstImageFromEvent(event) {
  const file =
    event?.dataTransfer?.files?.[0] ||
    event?.target?.files?.[0] ||
    event?.currentTarget?.files?.[0];

  if (!file || !String(file.type || "").startsWith("image/")) {
    return Promise.resolve(null);
  }

  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onerror = () => reject(new Error("Could not read that image."));
    reader.onload = () => {
      const result = typeof reader.result === "string" ? reader.result : "";
      resolve(result || null);
    };
    reader.readAsDataURL(file);
  });
}
