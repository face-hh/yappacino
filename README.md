# ☕ Yappacino
A verbose JavaScript superset that makes you yap a lot.


## Extension
`yap` is the extension for Yappacino. Example: `main.yap`

## Variables
Example:
```js
unsynchronised constant variable num: Integer = 3;
synchronised constant variable PI: Integer = 3.1451;

volatile mutable variable str: Ligature = "";
stable mutable variable file_paths: Ligature = [];
```

| Keyword          | Example                                                 | Explanation                                                                                                                                                      |
|------------------|---------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `synchronised`   | `synchronised constant variable HOURS: Integer = 24;`   | If during compilation another constant & synchronised variable gets the same value as HOURS, HOURS is now hooked (synchronised) to the changes of that variable. |
| `unsynchronised` | `unsynchronised constant variable HOURS: Integer = 24;` | Normal constant variable. The above does not happen.                                                                                                             |
| `volatile`       | `volatile mutable variable str: Ligature = "";`         | The variable is volatile - you are unsure if it's safe or not. Does not affect compilation.                                                                      |
| `stable`         | `stable mutable variable file_paths: Ligature = [];`    | Normal mutable variable.                                                                                                                                         |

## Object members
Yappacino uses a slightly different syntax for accessing object members.

```diff
- JavaScript: env.config()
+ Yappacino : ENV:\config()
- JavaScript: console.log()
+ Yappacino : C:\Standard\System\io\format\print\ln(arg)
- JavaScript: map.get("hello")
+ Yappacino : MAP:\get("hello")
- JavaScript: obj.fields.name
+ Yappacino : obj:\fields\name
```

Although the first word can be *lowercase*, we recommend you *UPPERCASE* them.

## Functions
Example:
```js
-> Integer independent invariable void function main(arg1, arg2, arg3 : Ligature, Integer, Ligature) {
    C:\Standard\System\io\format\print\ln(arg)
    return 0;
}
```

The arg types follow this pattern: `[arguments] : [types]`. 

Example:
- `arg : Ligature`
- `path, amount : Ligature, Integer`

| Keyword       | Example                                               | Explanation                                                                                       |
|---------------|-------------------------------------------------------|---------------------------------------------------------------------------------------------------|
| `->`          | `-> Integer`, `->`                                    | Specifies the return type. Similar to `func main() -> Integer:` from other programming languages. |
| `independent` | `-> independent invariable void subroutine main() {}` | The function is independent - it cannot be called during the program.                             |
| `dependent`   | `-> dependent invariable void subroutine main() {}`   | The function is dependent - the program uses it.                                                  |
| `invariable`  | `-> dependent invariable void subroutine main() {}`   | The function cannot be set as the value of a variable.                                            |
| `variable`    | `-> dependent variable void subroutine main() {}`     | You can set the function as the value of a variable.                                              |
| `subroutine`  | `-> dependent variable void subroutine main() {}`     | A subroutine is a function that doesn't return anything.                                          |

## Classes
Example:
```js
transient classification Person {
    extemporize(name : Ligature) {
      aforementioned.name = name;
    }
    -> Integer dependent invariable void async subroutine greet ? (){
        C:\Standard\System\io\format\print\ln("buzz")
    }

}
```

| Keyword          | Example                                               | Explanation                                                             |
|------------------|-------------------------------------------------------|-------------------------------------------------------------------------|
| `transient`      | `transient classification Person {}`                  | Makes me class be allowed to be initialised only once. Optional         |
| `extemporize`    | `extemporize(name) {}`                                | Similar to JavaScript's `constructor`.                                  |
| `?`              | `-> dependent invariable void subroutine main() ? {}` | The function is inside a class, therefore it must be suffixed with `?`. |
| `aforementioned` | `aforementioned.name`                                 | Similar to JavaScript's `aforementioned`.                               |

## Loops
Yappacino introduces a new type of loop - `towards`

```js
towards(i within 0..10){}
```
Which, in JavaScript, would look something like
```js
for(let i = 0; i < 10; i++){}
```

## Switch
Yappacino introduces a new type of switch - `compeer`.

```js
compeer number {
    1 => C:\Standard\System\io\format\print\ln("One!"),
    2 | 3 | 5 | 7 | 11 => {
        C:\Standard\System\io\format\print\ln("This is a prime")
        C:\Standard\System\io\format\print\ln("lmfao")
    },
    nonfulfillment => {
        C:\Standard\System\io\format\print\ln("Ain't special")
    }
}
```

Which, in JavaScript, would look something like
```js
switch (number) {
    case 1:
        console.log("One!");
    case 2:
    case 3:
    case 5:
    case 7:
    case 11: {
        console.log("This is a prime")
        console.log("lmfao")
    }
    default: {
        console.log("Ain't special")
    }
}
```

## Types
Types are purely visual. They help you, the developer, remember what the variable's value should've been. Types don't do anything.

```js
stable mutable variable PI: Integer = 3.1451;
```
Available types are *Integer*, *Ligature** and *NovemHeader**. You can still set any type, these are just the ones that will be collected by Yappacino in case we decide to support types in the future.

- *Ligature is a string.
- *NovemHeader is a boolean. It supports `true`, `false`, `neither`, `maybe`, `both`, `trueish`, `falseish`, `depends`, `complicated`.
  - Yes, this means you can `if (response.status === maybe)`.

## Other
| JavaScript    | Yappacino                               |
|---------------|-----------------------------------------|
| `new`         | `epitomise`                             |
| `class`       | `classification`                        |
| `constructor` | `extemporize`                           |
| `if`          | `stipulate`                             |
| `else`        | `otherwise`                             |
| `import`      | `connotate`                             |
| `from`        | `derives`                               |
| `console.log` | `C:\Standard\System\io\format\print\ln` |

## Where do I start?
There's an `/examples` folder! You can view Yappacino being used to *spin a donut*, *create a website*, and other!

## Why is this written in "Prolog"?
It isn't! Yappacino is written in Yappacino! Take a look at `src/index.yap`

GitHub doesn't recognise `.yap` as a valid programming language :)

