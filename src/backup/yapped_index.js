
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
import { readdir, stat, mkdir, rm } from "node:fs/promises";
import { join } from "node:path";
import { parseArgs } from "util";

const UTILS = String.raw`
const C = {Standard:{System:{io:{format:{print:{ln: console.log}}}}}}

const __BOOLEANS__ = {
    "NEITHER": 0.0001,
    "BOTH": 0.0002,
    "MAYBE": 0.0003,
    "TRUEISH": 0.0004,
    "FALSEISH": 0.0005,
    "DEPENDS": 0.0006,
    "COMPLICATED": 0.0007
}
`

const REGEX = {
    "match": /(compeer)\s+\w+\s+\{\s*(?:[^{}]*\{[^{}]*\}[^{}]*)*\}/g,
    "word_and_symbols": /([^\w]+)/,
    "types": /\s?:.*?\)/,
    "towards": /towards\s*\(\w{1}\s*within.+?\)\s*\{/g,
    "for": /for\((\w+)\s+within (.*)\.\.(.*)\)\s{/g,
    "switch": /switch\s*([^{]*)/,
    "match_cases": /(\d+)\s*(?:\|\s*)?/g,

    "variables": /(?:let|const)\s+(\w+|\[.*\]|\{.*\})\s*:\s*(\w+).*=/,
    "functions": /(\w+)\s*\(/,
    "classes": /class\s+(\w+)\s*(?:extends\s+\w+\s*)?\{/
}

const _TYPES_VARIABLES = new Map();
const _TYPES_FUNCTIONS = new Map();
const _TYPES_CLASSES = new Map();

let shut_the_fuck_up = false;

async function readDirRecursive(dir, res = []) {
    let files = await readdir(dir);
    for(let i = 0; i < files.length; i++){
        let file = files[i];

        const filePath = join(dir, file);
        const fileStat = await stat(filePath);

        if (file === "node_modules") continue;

        if (fileStat.isDirectory()) {
            res = await readDirRecursive(filePath, res);
        } else if (file.endsWith(".yap") || file.endsWith(".🗣️")) {
            res.push(filePath);
        }
    }

    return res;
}

function assert(str, search, or) {
    if (!str.includes(search) || or ? str.includes(or) : false) {
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
function replaceOrThrow(str, search, replace) {
    const res = str.replace(search, replace);
	if (res === str) {
        throw new Error(`Expected to find ${search} in ${str}`)
    }
    return res;
}

async function read(filePath) {
    const file = Bun.file(filePath);
    const contents = await file.text();

    return { contents, filePath };
}

async function emptyDist(PATH) {
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
async function saveToDist(content, filePath, PATH) {
    const relativePath = filePath.replace(/\.yap|.🗣️/, ".js");

    const distFilePath = relativePath.replace(PATH, PATH + "/dist");

    await mkdir(distFilePath.split("/").slice(0, -1).join("/"), { recursive: true });

    content = UTILS + content;

    Bun.write(distFilePath, content);
}

function throw_error(message) {
    if (shut_the_fuck_up) return;

    throw new Error(message);
}

function detectArgs(line) {
    const ARGS = line
        .match(/\((.*)\)/)[1] // "arg, arg2 : Ligature, Integer"
        .split(":") // ["arg1, arg2, arg3", "Ligature, Integer, Ligature"]

    for(let i = 0; i < ARGS.length; i++){
        ARGS[i] = ARGS[i].split(",").map(el => el.trim())
    }

    line = line.replace(REGEX.types, ")");

    return { ARGS, no_types_line: line }
}

const TYPES = ["Integer", "Ligature"]

const KEYWORDS = {
    "constant": (line) => {
        if(!/(?:^|\s)constant\s*/.test(line)) return line;
        
        assert(line, "variable");
        let is_synchronised = line.includes("synchronised");

        line = line.replace(/synchronised |unsynchronised /, "")
        if (!is_synchronised) assert(line, "unsynchronised")

        line = replaceOrThrow(line, "constant variable", "const");

        let _variable = REGEX.variables.exec(line);
// add error handling here pls lol, means no type on var
        _TYPES_VARIABLES.set(_variable[1], {
            "constant": true,
            is_synchronised,
            type: _variable[2]
        });

        return line;
    },
    "mutable": (line) => {
        if(!/(?:^|\s)mutable\s*/.test(line)) return line;
        
        assert(line, "variable");

        let is_volatile = line.includes("volatile");

        line = line.replace(/volatile |stable /, "")

        if (!is_volatile) assert(line, "stable")

        line = replaceOrThrow(line, "mutable variable", "let");

        let _variable = REGEX.variables.exec(line);
// error check here pls too
        _TYPES_VARIABLES.set(_variable[1], {
            "constant": false,
            is_volatile,
            type: _variable[2]
        });

        return line;
    },
    ":": (line) => {
        const TYPE = /(\w+|\{.*\}|\[.*\]):\s*(\w+)\s*=\s*(.*)/;

        if (!TYPE.test(line)) return line;

        // ----------- Example --------------
        // _        =     test = 3.0;
        // name     =     test
        // type     =     Integer
        // value    =     3.0
        const [_, name, type, value] = line.match(TYPE);

        line = replaceOrThrow(line, ": " + type, "")

        // TODO: ADD TYPES FOR _TYPE_VARIABLES HERE

        return line;
    },

    "->": (line) => {
        // Subroutine - functions that don't return anything
        let is_subroutine = line.includes("subroutine");

        // Independent - functions that don't get called
        let is_independent = line.includes("independent");
        // Invariable - functions that can't be assigned to a variable
        let is_invariable = line.includes("invariable");
        // Void - functions that return NULL/UNDEFINED
        let is_void = line.includes("void");
        let is_class_function = line.includes("?");

        line = line
            .replace(/subroutine/, "function")
            .replace(/(independent|dependent|invariable|variable|ratify|void|\s?\?\s?)/g, "");

        if (is_class_function) {
            line = line.replace(/function/, "")
        }
        if (!is_independent) assert("dependent", line);
        if (!is_invariable) assert("variable", line);
        if (!is_void) assert("ratify", line);

        // parse the function return type
        line = line.replace("->", "")

        let type = line.split(" ").filter(el => el !== "")[0];

        if (TYPES.includes(type)) {
            line = line.replace(type, "")
        }

        // replace whitespace until the first non-whitespace character
        line = line.replace(/^\s+/, "");

        const { ARGS, no_types_line } = detectArgs(line);

        line = no_types_line;

        let function_name = REGEX.functions.exec(line)[1];

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
        if (!/(?:^|\s)classification\s*/.test(line)) return line;
        let is_transient = line.includes("transient");

        line = line
            .replace(/classification/, "class")
            .replace(/transient /, "");

        let class_name = REGEX.classes.exec(line)[1];

        _TYPES_CLASSES.set(class_name, {
            is_transient
        })
        return line
    },
    "epitomise": (line) => {
        if(!/(?:^|\s)epitomise\s*/.test(line)) return line;
        line = line
            .replace(/epitomise/, "new")

        // TODO: detect in here if the class is already used, for is_transient
        return line
    },
    "extemporize": (line) => {
        if(!/(?:^|\s)extemporize\s*/.test(line)) return line;
        line = line
            .replace(/extemporize/, "constructor")

        const { ARGS, no_types_line } = detectArgs(line);
        // TODO: types
        line = no_types_line;

        return line
    },
    "aforementioned": (line) => {
        if(!/(?:^|\s)aforementioned\s*/.test(line)) return line;
        line = line
            .replace(/aforementioned/, "this")

        return line
    },
    "stipulate": (line) => {
        if(!/(?:^|\s)stipulate\s*/.test(line)) return line;
        line = line.replace(/stipulate/, "if")

        return line
    },
    "otherwise": (line) => {
        if(!/(?:^|\s)otherwise\s*/.test(line)) return line;
        line = line.replace(/otherwise/, "else")

        return line
    },
    "neither": (line) => {
        if(!/(?:^|\s)neither\s*/.test(line)) return line;
        return line.replace(/neither/, "__BOOLEANS__.NEITHER")
    },
    "both": (line) => {
        if(!/(?:^|\s)both\s*/.test(line)) return line;
        return line.replace(/both/, "__BOOLEANS__.BOTH")
    },
    "maybe": (line) => {
        if(!/(?:^|\s)maybe\s*/.test(line)) return line;
        return line.replace(/maybe/, "__BOOLEANS__.MAYBE")
    },
    "trueish": (line) => {
        if(!/(?:^|\s)trueish\s*/.test(line)) return line;
        return line.replace(/trueish/, "__BOOLEANS__.TRUEISH")
    },
    "falseish": (line) => {
        if(!/(?:^|\s)falseish\s*/.test(line)) return line;
        return line.replace(/falseish/, "__BOOLEANS__.FALSEISH")
    },
    "depends": (line) => {
        if(!/(?:^|\s)depends\s*/.test(line)) return line;
        return line.replace(/depends/, "__BOOLEANS__.DEPENDS")
    },
    "complicated": (line) => {
        if(!/(?:^|\s)complicated\s*/.test(line)) return line;
        return line.replace(/complicated/, "__BOOLEANS__.COMPLICATED")
    },
    "connotate": (line) => {
        if(!/(?:^|\s)connotate\s*/.test(line)) return line;
        line = line.replace(/connotate/, "import")
        line = line.replace(/derives/, "from")

        return line
    },
    "towards": (line) => {
        if(!/(?:^|\s)true\s*/.test(line)) return line;
        line = line.replace(/towards/, "for")

        return line
    },
    "asynchronous": (line) => {
        if (!/(?:^|\s)asynchronous\s*/.test(line)) return line;
        line = line.replace(/asynchronous/, "async")
        return line
    },
    "anticipate": (line) => {
        if (!/(?:^|\s)anticipate\s*/.test(line)) return line;
        line = line.replace(/anticipate/, "await")
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
    const { values } = parseArgs({
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

    let PATH = Bun.argv[2]

    if (PATH === "." || !PATH || PATH.includes("--")) PATH = process.cwd()

    await emptyDist(PATH);

    const files = await readDirRecursive(PATH);

    for (const filePath of files) {
        let { contents } = await read(filePath);

        contents = contents.split("\n");

        for(let i = 0; i < contents.length; i++){
            let line = contents[i];

            const CHARS = line.split(REGEX.word_and_symbols);

            for(let J = 0; J < CHARS.length; J++){
                let char = CHARS[J].trim();

                char = char.replace(/\s+$/, "");

                const RESERVED = KEYWORDS[char];

                for(let k = 0; k < _TYPES_FUNCTIONS.size; k++){
                    if (char === Array.from(_TYPES_FUNCTIONS.keys())[k]) {
                        let types = _TYPES_FUNCTIONS.get(char);

                        if(!contents[i].includes("->") && types.is_independent) throw_error(`Function ${char} cannot be called because it is "independent".`);
                        if(/\bvariable\b/.test(contents[i]) && types.is_invariable) throw_error(`Function ${char} cannot be set to a variable because it is "invariable".`);
                    }
                }

                if (!RESERVED) continue;

                line = RESERVED(line);
            }

            contents[i] = line;
        }

        contents = contents.join("\n");

		const compeers = contents.match(REGEX.match) || [];
        for (const _compeer of compeers) {
            let body = _compeer.replace(/^\s*compeer\s*/gm, "switch").trim();

            const SWITCH = body.match(REGEX.switch);
            if (SWITCH) {
                body = body.replace(SWITCH[1], `(${SWITCH[1]})`);
            }

            const PARTS = body.split("\n")

            // 1 because we gotta skip the first
            for(let i = 0; i < PARTS.length; i++){
                let part = PARTS[i]

                if (part.includes("nonfulfillment")) {
                    part = part.replace("nonfulfillment", "default")
                    part = part.replace("=>", ":")
                } else if (!part.includes("=>")) {
                    // this part doesn't include a case
                    part = part.replace(/},/g, "\nbreak;\n}")
                }
                const matches = part.match(REGEX.match_cases) || [];
                const jsCases = matches.map(match => `  case ${match.replace(/\s*\|\s*/, '').trim()}:\n`).join('');;

                part = jsCases + part.replace(REGEX.match_cases, '');
                part = part.replace("=>", "")

                part = part.replace(/,$/g, ";break;")

                PARTS[i] = part
            }

            contents = contents.replace(_compeer, PARTS.join("\n"))
        }

        const _towards = contents.match(REGEX.towards) || [];

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
