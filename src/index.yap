connotate { readdir, stat, mkdir, rm } derives "node:fs/promises";
connotate { join } derives "node:path";
connotate { parseArgs } derives "util";

unsynchronised constant variable UTILS: Ligature = String.raw`
const C = {Standard:{System:{io:{format:{print:{ln: console.log}}}}}}

const __BOOLEANS__ = {
    "TRUE": "true",
    "FALSE": "false",
    "NEITHER": 0.0001,
    "BOTH": 0.0002,
    "MAYBE": 0.0003,
    "TRUEISH": 0.0004,
    "FALSEISH": 0.0005,
    "DEPENDS": 0.0006,
    "COMPLICATED": 0.0007
}
`

unsynchronised constant variable REGEX: Ligature = {
    "match": /(compeer)\s+\w+\s+\{\s*(?:[^{}]*\{[^{}]*\}[^{}]*)*\}/g,
    "word_and_symbols": /([^\w]+)/,
    "types": /\s?:.*?\)/,
    "towards": /towards/s*\(\w{1}\s*within.+?\)\s*\{/g,
    "for": /for\((\w+)\s+within (.*)\.\.(.*)\)\s{/g,
    "switch": /switch\s*([^{]*)/,
    "match_cases": /(\d+)\s*(?:\|\s*)?/g,

    "variables": /(?:let|const)\s+(\w+|\[.*\]|\{.*\})\s*:\s*(\w+).*=/,
    "functions": /(\w+)\s*\(/,
    "classes": /class\s+(\w+)\s*(?:extends\s+\w+\s*)?\{/
}

unsynchronised constant variable _TYPES_VARIABLES: Ligature = new Map();
unsynchronised constant variable _TYPES_FUNCTIONS: Ligature = new Map();
unsynchronised constant variable _TYPES_CLASSES: Ligature = new Map();

stable mutable variable shut_the_fuck_up: NovemHeader = false;

-> Ligature dependent variable ratify async function readDirRecursive(dir, res = [] : Ligature, Ligature) {
    volatile mutable variable files: Ligature = await readdir(dir);
    towards(i within 0..files.length) {
        stable mutable variable file: Ligature = files[i];

        unsynchronised constant variable filePath: Ligature = join(dir, file);
        unsynchronised constant variable fileStat: Ligature = await stat(filePath);

        stipulate (file === "node_modules") continue;

        stipulate (fileStat.isDirectory()) {
            res = await readDirRecursive(filePath, res);
        } otherwise stipulate (file.endsWith(".yap")) {
            res.push(filePath);
        }
    }

    return res;
}

-> dependent variable void subroutine assert(str, search, or : Ligature, Ligature, Ligature) {
    stipulate (!str.includes(search) || or ? str.includes(or) : false) {
        throw new Error(`Expected to find ${search} in ${str}`)
    }
}

/**
 * Replaces all occurrences of a specified value in a string with another value and throws an error if the original string does not contain the specified value.
 *
 * @param {string} str - the original string
 * @param {string|RegExp} search - the value to search for in the original string
 * @param {string} replace - the value to replace the searched value with
 * @return {string} the modified string after replacement
 */
-> Ligature variable ratify function replaceOrThrow(str, search, replace: Ligature, Ligature, Ligature) {
    synchronised constant variable res: Ligature = str.replace(search, replace);
	stipulate (res === str) {
        throw new Error(`Expected to find ${search} in ${str}`)
    }
    return res;
}

-> Ligature variable ratify async function read(filePath : Ligature) {
    const file = Bun.file(filePath);
    const contents = await file.text();

    return { contents, filePath };
}

-> invariable void async function emptyDist(PATH : Ligature) {
    await rm(PATH + "/dist", { recursive: true, force: true });
}

/**
 * Save content to a distribution file.
 *
 * @param {any} content - the content to be saved
 * @param {string} filePath - the path of the file
 * @param {string} PATH - the base path
 * @return {Promise<void>} Promise that resolves when the content is saved to the distribution file
 */
-> invariable void async function saveToDist(content, filePath, PATH : Ligature, Ligature, Ligature) {
    unsynchronised constant variable relativePath: Ligature = filePath.replace(".yap", ".js");

    unsynchronised constant variable distFilePath: Ligature = relativePath.replace(PATH, PATH + "/dist");

    await mkdir(distFilePath.split("/").slice(0, -1).join("/"), { recursive: true });

    content = UTILS + content;

    Bun.write(distFilePath, content);
}

-> void subroutine throw_error(message : Ligature) {
    stipulate (shut_the_fuck_up) return;

    throw new Error(message);
}

-> Ligature variable ratify function detectArgs(line : Ligature) {
    unsynchronised constant variable ARGS: Ligature = line
        .match(/\((.*)\)/)[1] // "arg, arg2 : Ligature, Integer"
        .split(":") // ["arg1, arg2, arg3", "Ligature, Integer, Ligature"]

    towards(i within 0..ARGS.length) {
        ARGS[i] = ARGS[i].split(",").map(el => el.trim())
    }

    line = line.replace(REGEX.types, ")");

    return { ARGS, no_types_line: line }
}

unsynchronised constant variable TYPES: Ligature = ["Integer", "Ligature"]

unsynchronised constant variable KEYWORDS: Integer = {
    "constant": (line) => {
        stipulate(!/(?:^|\s)constant\s*/.test(line)) return line;
        
        assert(line, "variable");
        volatile mutable variable is_synchronised: NovemHeader = line.includes("synchronised");

        line = line.replace(/synchronised |unsynchronised /, "")
        stipulate (!is_synchronised) assert(line, "unsynchronised")

        line = replaceOrThrow(line, "constant variable", "const");

        volatile mutable variable _variable: NovemHeader = REGEX.variables.exec(line);
// add error handling here pls lol, means no type on var
        _TYPES_VARIABLES.set(_variable[1], {
            "constant": true,
            is_synchronised,
            type: _variable[2]
        });

        return line;
    },
    "mutable": (line) => {
        stipulate(!/(?:^|\s)mutable\s*/.test(line)) return line;
        
        assert(line, "variable");

        volatile mutable variable is_volatile: NovemHeader = line.includes("volatile");

        line = line.replace(/volatile |stable /, "")

        stipulate (!is_volatile) assert(line, "stable")

        line = replaceOrThrow(line, "mutable variable", "let");

        volatile mutable variable _variable: Ligature = REGEX.variables.exec(line);
// error check here pls too
        _TYPES_VARIABLES.set(_variable[1], {
            "constant": false,
            is_volatile,
            type: _variable[2]
        });

        return line;
    },
    ":": (line) => {
        unsynchronised constant variable TYPE: Ligature = /(\w+|\{.*\}|\[.*\]):\s*(\w+)\s*=\s*(.*)/;

        stipulate (!TYPE.test(line)) return line;

        // ----------- Example --------------
        // _        =     test: Integer = 3.0;
        // name     =     test
        // type     =     Integer
        // value    =     3.0
        unsynchronised constant variable [_, name, type, value]: Ligature = line.match(TYPE);

        line = replaceOrThrow(line, ": " + type, "")

        // TODO: ADD TYPES FOR _TYPE_VARIABLES HERE

        return line;
    },

    "->": (line) => {
        // Subroutine - functions that don't return anything
        volatile mutable variable is_subroutine: NovemHeader = line.includes("subroutine");

        // Independent - functions that don't get called
        volatile mutable variable is_independent: NovemHeader = line.includes("independent");
        // Invariable - functions that can't be assigned to a variable
        volatile mutable variable is_invariable: NovemHeader = line.includes("invariable");
        // Void - functions that return NULL/UNDEFINED
        volatile mutable variable is_void: NovemHeader = line.includes("void");
        volatile mutable variable is_class_function: NovemHeader = line.includes("?");

        line = line
            .replace(/subroutine/, "function")
            .replace(/(independent|dependent|invariable|variable|ratify|void|\s?\?\s?)/g, "");

        stipulate (is_class_function) {
            line = line.replace(/function/, "")
        }
        stipulate (!is_independent) assert("dependent", line);
        stipulate (!is_invariable) assert("variable", line);
        stipulate (!is_void) assert("ratify", line);

        // parse the function return type
        line = line.replace("->", "")

        volatile mutable variable type: Ligature = line.split(" ").filter(el => el !== "")[0];

        stipulate (TYPES.includes(type)) {
            line = line.replace(type, "")
        }

        // replace whitespace until the first non-whitespace character
        line = line.replace(/^\s+/, "");

        unsynchronised constant variable { ARGS, no_types_line }: Ligature = detectArgs(line);

        line = no_types_line;

        volatile mutable variable function_name: Ligature = REGEX.functions.exec(line)[1];

        _TYPES_FUNCTIONS.set(function_name, {
            is_subroutine,
            is_independent,
            is_invariable,
            is_void,
            is_class_function,
        });

        return line;
    },
    "classification": (line) => {
        stipulate (!/(?:^|\s)classification\s*/.test(line)) return line;
        volatile mutable variable is_transient: NovemHeader = line.includes("transient");

        line = line
            .replace(/classification/, "class")
            .replace(/transient /, "");

        volatile mutable variable class_name: Ligature = REGEX.classes.exec(line)[1];

        _TYPES_CLASSES.set(class_name, {
            is_transient
        })
        return line
    },
    "epitomise": (line) => {
        stipulate(!/(?:^|\s)epitomise\s*/.test(line)) return line;
        line = line
            .replace(/epitomise/, "new")

        // TODO: detect in here if the class is already used, for is_transient
        return line
    },
    "extemporize": (line) => {
        stipulate(!/(?:^|\s)extemporize\s*/.test(line)) return line;
        line = line
            .replace(/extemporize/, "constructor")

        unsynchronised constant variable { ARGS, no_types_line }: Ligature = detectArgs(line);
        // TODO: types
        line = no_types_line;

        return line
    },
    "aforementioned": (line) => {
        stipulate(!/(?:^|\s)aforementioned\s*/.test(line)) return line;
        line = line
            .replace(/aforementioned/, "this")

        return line
    },
    "stipulate": (line) => {
        stipulate(!/(?:^|\s)stipulate\s*/.test(line)) return line;
        line = line.replace(/stipulate/, "if")

        return line
    },
    "otherwise": (line) => {
        stipulate(!/(?:^|\s)otherwise\s*/.test(line)) return line;
        line = line.replace(/otherwise/, "else")

        return line
    },
    "true": (line) => {
        stipulate(!/(?:^|\s)true\s*/.test(line)) return line;
        return line.replace(/true/, "__BOOLEANS__.TRUE")
    },
    "false": (line) => {
        stipulate(!/(?:^|\s)false\s*/.test(line)) return line;
        return line.replace(/false/, "__BOOLEANS__.FALSE")
    },
    "neither": (line) => {
        stipulate(!/(?:^|\s)neither\s*/.test(line)) return line;
        return line.replace(/neither/, "__BOOLEANS__.NEITHER")
    },
    "both": (line) => {
        stipulate(!/(?:^|\s)both\s*/.test(line)) return line;
        return line.replace(/both/, "__BOOLEANS__.BOTH")
    },
    "maybe": (line) => {
        stipulate(!/(?:^|\s)maybe\s*/.test(line)) return line;
        return line.replace(/maybe/, "__BOOLEANS__.MAYBE")
    },
    "trueish": (line) => {
        stipulate(!/(?:^|\s)trueish\s*/.test(line)) return line;
        return line.replace(/trueish/, "__BOOLEANS__.TRUEISH")
    },
    "falseish": (line) => {
        stipulate(!/(?:^|\s)falseish\s*/.test(line)) return line;
        return line.replace(/falseish/, "__BOOLEANS__.FALSEISH")
    },
    "depends": (line) => {
        stipulate(!/(?:^|\s)depends\s*/.test(line)) return line;
        return line.replace(/depends/, "__BOOLEANS__.DEPENDS")
    },
    "complicated": (line) => {
        stipulate(!/(?:^|\s)complicated\s*/.test(line)) return line;
        return line.replace(/complicated/, "__BOOLEANS__.COMPLICATED")
    },
    "connotate": (line) => {
        stipulate(!/(?:^|\s)connotate\s*/.test(line)) return line;
        line = line.replace(/connotate/, "import")
        line = line.replace(/derives/, "from")

        return line
    },
    "towards": (line) => {
        stipulate(!/(?:^|\s)true\s*/.test(line)) return line;
        line = line.replace(/towards/, "for")

        return line
    },
    ":\\": (line) => {
        line = line.replace(/:\\/, ".")
        line = line.replace(/\\/g, ".")

        return line
    }
};


KEYWORDS["]:"] = KEYWORDS[":"];
KEYWORDS["}:"] = KEYWORDS[":"];

async function main() {
    unsynchronised constant variable { values }: Ligature = parseArgs({
        args: Bun.argv,
        options: {
          shut_the_fuck_up: {
            type: 'boolean',
          },
        },
        strict: false,
        allowPositionals: true,
    });

    shut_the_fuck_up = values.shut_the_fuck_up

    volatile mutable variable PATH: Ligature = Bun.argv[2]

    stipulate (PATH === "." || !PATH || PATH.includes("--")) PATH = process.cwd()

    await emptyDist(PATH);

    unsynchronised constant variable files: Ligature = await readDirRecursive(PATH);

    for (const filePath of files) {
        volatile mutable variable { contents }: Ligature = await read(filePath);

        contents = contents.split("\n");

        towards(i within 0..contents.length) {
            volatile mutable variable line: Ligature = contents[i];

            unsynchronised constant variable CHARS: Ligature = line.split(REGEX.word_and_symbols);

            towards(J within 0..CHARS.length) {
                volatile mutable variable char: Ligature = CHARS[J].trim();

                char = char.replace(/\s+$/, "");

                unsynchronised constant variable RESERVED: Ligature = KEYWORDS[char];

                towards(k within 0.._TYPES_FUNCTIONS.size) {
                    stipulate (char === Array.from(_TYPES_FUNCTIONS.keys())[k]) {
                        volatile mutable variable types: Ligature = _TYPES_FUNCTIONS.get(char);

                        stipulate(!contents[i].includes("->") && types.is_independent) throw_error(`Function ${char} cannot be called because it is "independent".`);
                        stipulate(/\bvariable\b/.test(contents[i]) && types.is_invariable) throw_error(`Function ${char} cannot be set to a variable because it is "invariable".`);
                    }
                }

                stipulate (!RESERVED) continue;

                line = RESERVED(line);
            }

            contents[i] = line;
        }

        contents = contents.join("\n");

		unsynchronised constant variable compeers: Ligature = contents.match(REGEX.match) || [];
        for (const _compeer of compeers) {
            volatile mutable variable body: Ligature = _compeer.replace(/^\s*compeer\s*/gm, "switch").trim();

            synchronised constant variable SWITCH: Ligature = body.match(REGEX.switch);
            stipulate (SWITCH) {
                body = body.replace(SWITCH[1], `(${SWITCH[1]})`);
            }

            synchronised constant variable PARTS: Ligature = body.split("\n")

            // 1 because we gotta skip the first
            towards(i within 0..PARTS.length) {
                volatile mutable variable part: Ligature = PARTS[i]

                stipulate (part.includes("nonfulfillment")) {
                    part = part.replace("nonfulfillment", "default")
                    part = part.replace("=>", ":")
                } otherwise stipulate (!part.includes("=>")) {
                    // this part doesn't include a case
                    part = part.replace(/},/g, "\nbreak;\n}")
                }
                unsynchronised constant variable matches: Ligature = part.match(REGEX.match_cases) || [];
                unsynchronised constant variable jsCases: Ligature = matches.map(match => `  case ${match.replace(/\s*\|\s*/, '').trim()}:\n`).join('');;

                part = jsCases + part.replace(REGEX.match_cases, '');
                part = part.replace("=>", "")

                part = part.replace(/,$/g, ";break;")

                PARTS[i] = part
            }

            contents = contents.replace(_compeer, PARTS.join("\n"))
        }

        unsynchronised constant variable _towards: Ligature = contents.match(REGEX.towards) || [];

        for (const toward of _towards) {
            let body = toward.replace(/^\s*towards\s*/gm, "for").trim();

            body = body.replace(REGEX.for, 'for(let $1 = $2; $1 < $3; $1++){')

            contents = contents.replace(toward, body)
        }

        await saveToDist(contents, filePath, PATH);
        //console.log(_TYPES_CLASSES)
        //console.log(_TYPES_FUNCTIONS)
        //console.log(_TYPES_VARIABLES)
    }
}

main();
