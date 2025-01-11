import fs from "fs";

function getRemappings() {
    return fs
        .readFileSync("remappings.txt", "utf8")
        .split("\n")
        .filter(Boolean)
        .map((line) => line.trim().split("="));
}

export function transformLine(line: string) {
    if (line.match(/^\s*import /i) || line.match(/ from ['"]/i) || line.match(/    "/i)) {
        getRemappings().forEach(([find, replace]) => {
        if (line.match('"' + find)) {
            line = line.replace('"' + find, '"' + replace);
        }
        });
    }
    return line;
}

  