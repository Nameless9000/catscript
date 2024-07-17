--
-- catlib.lua - Because visual programming languages should die.
--
-- Copyright (c) 2024 Nameless9000
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local json = require("json")

local bytemarkers = { {0x7FF,192}, {0xFFFF,224}, {0x1FFFFF,240} }

local function to_globalid(decimal: number): string
    if decimal<128 then
        return string.char(decimal)
    end

    local charbytes = {}
    for bytes,vals in ipairs(bytemarkers) do
        if decimal<=vals[1] then
            for b=bytes+1,2,-1 do
                local mod = decimal%64
                decimal = (decimal-mod)/64
                charbytes[b] = string.char(128+mod)
            end
            charbytes[1] = string.char(vals[2]+decimal)
            break
        end
    end
return table.concat(charbytes)
end

--------------------
----- Variable -----
--------------------
type VariableImpl = {
    __index: VariableImpl;

    Get: (name: string) -> string;
    Set: (name: string, script_obj: ScriptObj, value: string) -> ();
    Increase: (name: string, script_obj: ScriptObj, by: string) -> ();
    Decrease: (name: string, script_obj: ScriptObj, by: string) -> ();
    Multiply: (name: string, script_obj: ScriptObj, by: string) -> ();
    Divide: (name: string, script_obj: ScriptObj, by: string) -> ();
    Round: (name: string, script_obj: ScriptObj) -> ();
    Floor: (name: string, script_obj: ScriptObj) -> ();
    SetRandom: (name: string, script_obj: ScriptObj, min: string, max: string) -> ();
    SetToTextFromInput: (name: string, script_obj: ScriptObj, globalid: number) -> ();
}

local Variable: VariableImpl = {} :: VariableImpl
Variable.__index = Variable

function Variable.Get(name)
   return `\{{name}\}` 
end
function Variable.Set(name, script_obj, value)
    table.insert(script_obj.data, {
        id = "11";
        text = {
            "Set variable",
            {
                value = name;
                t = "string";
            },
            "to",
            {
                value = value;
                t = "any";
            }
        }
    })
end
function Variable.Increase(name, script_obj, by)
    table.insert(script_obj.data, {
        id = "12";
        text = {
            "Increase",
            {
                value = name;
                t = "string";
            },
            "by",
            {
                value = by;
                t = "number";
            }
        }
    })
end
function Variable.Decrease(name, script_obj, by)
    table.insert(script_obj.data, {
        id = "13";
        text = {
            "Subtract",
            {
                value = name;
                t = "string";
            },
            "by",
            {
                value = by;
                t = "number";
            }
        }
    })
end
function Variable.Multiply(name, script_obj, by)
    table.insert(script_obj.data, {
        id = "14";
        text = {
            "Multiply",
            {
                value = name;
                t = "string";
            },
            "by",
            {
                value = by;
                t = "number";
            }
        }
    })
end
function Variable.Divide(name, script_obj, by)
    table.insert(script_obj.data, {
        id = "15";
        text = {
            "Divide",
            {
                value = name;
                t = "string";
            },
            "by",
            {
                value = by;
                t = "number";
            }
        }
    })
end
function Variable.Round(name, script_obj)
    table.insert(script_obj.data, {
        id = "16";
        text = {
            "Round",
            {
                value = name;
                t = "string";
            }
        }
    })
end
function Variable.Floor(name, script_obj)
    table.insert(script_obj.data, {
        id = "17";
        text = {
            "Floor",
            {
                value = name;
                t = "string";
            }
        }
    })
end
function Variable.SetRandom(name, script_obj, min, max)
    table.insert(script_obj.data, {
        id = "27";
        text = {
            "Set",
            {
                value = name;
                t = "string";
            },
            "to random",
            {
                value = min;
            },
            "-",
            {
                value = max;
            }
        }
    })
end
function Variable.SetToTextFromInput(name, script_obj, globalid)
    table.insert(script_obj.data, {
        id = "30";
        text = {
            "Set",
            {
                value = name;
                t = "string";
            },
            "to text from",
            {
                value = to_globalid(globalid);
                t = "object";
            }
        }
    })
end

-------------------------
----- Script Object -----
-------------------------
type ScriptObjImpl = {
    __index: ScriptObjImpl;
    new: () -> ScriptObj;

    Log: (self: ScriptObj, string: string) -> ();
    Warn: (self: ScriptObj, string: string) -> ();
    Error: (self: ScriptObj, string: string) -> ();

    Wait: (self: ScriptObj, seconds: string) -> ();
    IfEqual: (self: ScriptObj, a: string, b: string) -> ();
    IfNotEqual: (self: ScriptObj, a: string, b: string) -> ();
    IfGreater: (self: ScriptObj, a: string, b: string) -> ();
    IfLower: (self: ScriptObj, a: string, b: string) -> ();

    Repeat: (self: ScriptObj, times: string) -> ();
    RepeatForever: (self: ScriptObj) -> ();

    Redirect: (self: ScriptObj, to: string) -> ();

    PlayAudio: (self: ScriptObj, id: string) -> ();
    PlayAudioLooped: (self: ScriptObj, id: string) -> ();
    SetAudioVolume: (self: ScriptObj, value: string) -> ();
    StopAllAudio: (self: ScriptObj) -> ();
    PauseAllAudio: (self: ScriptObj) -> ();
    ResumeAllAudio: (self: ScriptObj) -> ();

    MakeObjectInvisible: (self: ScriptObj, globalid: number) -> ();
    MakeObjectVisible: (self: ScriptObj, globalid: number) -> ();
    SetObjectText: (self: ScriptObj, globalid: number, text: string) -> ();
    SetObjectProperty: (self: ScriptObj, globalid: number, property: string, value: string) -> ();

    End: (self: ScriptObj) -> ();
}

type ScriptObj = typeof(setmetatable({} :: {
    data: {any}
}, {} :: ScriptObjImpl))

local ScriptObj: ScriptObjImpl = {} :: ScriptObjImpl
ScriptObj.__index = ScriptObj

function ScriptObj.new()
    return setmetatable({
        data = {}
    }, ScriptObj)
end

function ScriptObj:Log(data)
    table.insert(self.data, {
        id = "0";
        text = {
            "Log",
            {
                value = data;
                t = "string";
            }
        }
    })
end
function ScriptObj:Warn(data)
    table.insert(self.data, {
        id = "1";
        text = {
            "Warn",
            {
                value = data;
                t = "string";
            }
        }
    })
end
function ScriptObj:Error(data)
    table.insert(self.data, {
        id = "2";
        text = {
            "Error",
            {
                value = data;
                t = "string";
            }
        }
    })
end

function ScriptObj:Wait(seconds)
    table.insert(self.data, {
        id = "3";
        text = {
            "Wait",
            {
                value = seconds;
                t = "number";
            }
        }
    })
end
function ScriptObj:IfEqual(a, b)
    table.insert(self.data, {
        id = "18";
        text = {
            "If",
            {
                value = a;
                t = "any";
            },
            "is equal to",
            {
                value = b;
                t = "any";
            }
        }
    })
end
function ScriptObj:IfNotEqual(a, b)
    table.insert(self.data, {
        id = "19";
        text = {
            "If",
            {
                value = a;
                t = "any";
            },
            "is not equal to",
            {
                value = b;
                t = "any";
            }
        }
    })
end
function ScriptObj:IfGreater(a, b)
    table.insert(self.data, {
        id = "20";
        text = {
            "If",
            {
                value = a;
                t = "any";
            },
            "is greater than",
            {
                value = b;
                t = "any";
            }
        }
    })
end
function ScriptObj:IfLower(a, b)
    table.insert(self.data, {
        id = "21";
        text = {
            "If",
            {
                value = a;
                t = "any";
            },
            "is lower than",
            {
                value = b;
                t = "any";
            }
        }
    })
end

function ScriptObj:Repeat(times)
    table.insert(self.data, {
        id = "22";
        text = {
            "Repeat",
            {
                value = times;
                t = "number";
            },
            "times"
        }
    })
end
function ScriptObj:RepeatForever()
    table.insert(self.data, {
        id = "23";
        text = {
            "Repeat forever"
        }
    })
end

function ScriptObj:Redirect(to)
    table.insert(self.data, {
        id = "4";
        text = {
            "Redirect",
            {
                value = to;
                t = "string";
            }
        }
    })
end

function ScriptObj:PlayAudio(id)
    table.insert(self.data, {
        id = "5";
        text = {
            "Play audio",
            {
                value = id;
                t = "string";
            }
        }
    })
end
function ScriptObj:PlayAudioLooped(id)
    table.insert(self.data, {
        id = "26";
        text = {
            "Play audio",
            {
                value = id;
                t = "string";
            }
        }
    })
end
function ScriptObj:SetAudioVolume(volume)
    table.insert(self.data, {
        id = "6";
        text = {
            "Play audio",
            {
                value = volume;
                t = "number";
            }
        }
    })
end
function ScriptObj:StopAllAudio()
    table.insert(self.data, {
        id = "7";
        text = {"Stop all audio"}
    })
end
function ScriptObj:PauseAllAudio()
    table.insert(self.data, {
        id = "28";
        text = {"Pause all audio"}
    })
end
function ScriptObj:ResumeAllAudio()
    table.insert(self.data, {
        id = "29";
        text = {"Resume all audio"}
    })
end

function ScriptObj:MakeObjectInvisible(globalid)
    table.insert(self.data, {
        id = "8";
        text = {
            "Make",
            {
                value = to_globalid(globalid);
                t = "object";
            },
            "invisible"
        }
    })
end
function ScriptObj:MakeObjectVisible(globalid)
    table.insert(self.data, {
        id = "9";
        text = {
            "Make",
            {
                value = to_globalid(globalid);
                t = "object";
            },
            "visible"
        }
    })
end
function ScriptObj:SetObjectText(globalid, text)
    table.insert(self.data, {
        id = "10";
        text = {
            "Set",
            {
                value = to_globalid(globalid);
                t = "object";
            },
            "text to",
            {
                value = text;
                t = "string";
            }
        }
    })
end
function ScriptObj:SetObjectProperty(globalid, property, value)
    table.insert(self.data, {
        id = "10";
        text = {
            "Set prop",
            {
                value = property;
                t = "string";
            },
            "of",
            {
                value = to_globalid(globalid);
                t = "object";
            },
            "to",
            {
                value = value;
                t = "any";
            }
        }
    })
end

function ScriptObj:End()
    table.insert(self.data, {
        id = "25";
        text = {"end"};
    })
end

---------------------
----- CatScript -----
---------------------
type CatScriptImpl = {
    __index: CatScriptImpl;
    new: () -> CatScript;
    Export: (self: CatScript, globalid: number?) -> string;

    Loaded: (self: CatScript, script_data: ScriptObj) -> ();
    ButtonPressed: (self: CatScript, globalid: number, script_data: ScriptObj) -> ();
    ButtonHovered: (self: CatScript, globalid: number, script_data: ScriptObj) -> ();
    KeyPressed: (self: CatScript, key: string, script_data: ScriptObj) -> ();
}

type CatScript = typeof(setmetatable({} :: {
    data: {any}
}, {} :: CatScriptImpl))

local CatScript: CatScriptImpl = {} :: CatScriptImpl
CatScript.__index = CatScript

function CatScript.new()
    return setmetatable({
        data = {}
    }, CatScript)
end

-- Only these two annotations are necessary
function CatScript:Loaded(script_data)
    table.insert(self.data, {
        id = "0";
        text = {};
        actions = script_data;
    })
end
function CatScript:ButtonPressed(globalid, script_data)
    table.insert(self.data, {
        id = "1";
        text = {
            "When",
            {
                value = to_globalid(globalid);
                t = "object";
            },
            "pressed..."
        };
        actions = script_data;
    })
end
function CatScript:ButtonHovered(globalid, script_data)
    table.insert(self.data, {
        id = "3";
        text = {
            "When",
            {
                value = to_globalid(globalid);
                t = "object";
            },
            "hovered..."
        };
        actions = script_data;
    })
end
function CatScript:KeyPressed(key, script_data)
    table.insert(self.data, {
        id = "2";
        text = {
            "When",
            {
                value = key
            },
            "pressed..."
        };
        actions = script_data;
    })
end

function CatScript:Export(globalid)
    local export_data = {
        {
            class = "script";
            globalid = to_globalid(globalid or 1);
            content = self.data;
        }
    }

    return json.encode(export_data)
end

--------------------------
----- Code Injection -----
--------------------------
local main_script = CatScript.new()
local main_script_context = ScriptObj.new()
local tmp_var_count = 0

main_script:Loaded(main_script_context)

local function get_script_context(): ScriptObj
    local script_context = getfenv(debug.info(3, "f"))["__SCRIPT_CONTEXT__"]
    assert(script_context, "script context was not found")
    return script_context
end

local branch_types = {
    IF = 1;
    REPEAT = 2;
}
local branch_stack = {}
local function if_eq_handler(a, b)
    table.insert(branch_stack, {branch_types.IF})
    if typeof(a) == "table" then
        a = Variable.Get(a[1])
    end
    if typeof(b) == "table" then
        b = Variable.Get(b[1])
    end
    get_script_context():IfEqual(a, b)
    print(`IF {a} == {b}`)
end
local function repeat_handler(times: number?)
    table.insert(branch_stack, {branch_types.REPEAT})

    if times == nil then
        get_script_context():RepeatForever()
    else
        get_script_context():Repeat(tostring(times))
    end
end
local function end_handler()
    assert(#branch_stack > 0, "unexpected end statement")

    get_script_context():End()
    table.remove(branch_stack, #branch_stack)
end

local function print_handler(...)
    get_script_context():Log(table.concat({...}, " "))
end
local function warn_handler(...)
    get_script_context():Warn(table.concat({...}, " "))
end
local function error_handler(...)
    get_script_context():Error(table.concat({...}, " "))
end

local function create_button(globalid)
    return {
        OnClick = function(callback)
            local script_context = ScriptObj.new()
            main_script:ButtonPressed(globalid, script_context)

            local env = getfenv(debug.info(2, "f"))
            local old_script_context = env["__SCRIPT_CONTEXT__"]

            env["__SCRIPT_CONTEXT__"] = script_context
            setfenv(callback, env)

            callback()

            env["__SCRIPT_CONTEXT__"] = old_script_context
            setfenv(callback, env)
        end
    }
end

local function create_text(globalid)
    return setmetatable({}, {
        __newindex = function(self, i, v)
            if i == "Text" then
                if typeof(v) == "table" then
                    print(`TEXT {globalid} = {v[1]}`)
                    get_script_context():SetObjectText(globalid, Variable.Get(v[1]))
                elseif typeof(v) == "string" then
                    print(`TEXT {globalid} = "{v}"`)
                    get_script_context():SetObjectText(globalid, v)
                end
            end
        end
    })
end

return function()
    local func = debug.info(2, "f")
    local env = {}

    env["Button"] = create_button
    env["Text"] = create_text

    env["REPEAT"] = repeat_handler
    env["IF_EQ"] = if_eq_handler
    env["END"] = end_handler

    env["print"] = print_handler
    env["warn"] = warn_handler
    env["error"] = error_handler

    env["__SCRIPT_CONTEXT__"] = main_script_context

    -- handle env
    local var_env = {}
    env = setmetatable(env, {
        __index = function(self, i)
            local var = rawget(var_env, i)
            if var then
                print(`GET {i}`)
                return setmetatable({i}, {
                    __add = function(_, b)
                        print(`ADD {i} + {b}`)
                        local script_obj = get_script_context()

                        tmp_var_count += 1
                        local tmp_var = `_{tmp_var_count}`
                        Variable.Set(tmp_var, script_obj, Variable.Get(i))
                        Variable.Increase(tmp_var, script_obj, b)

                        return Variable.Get(tmp_var)
                    end
                })
            end

            return rawget(self, i)
        end,
        __newindex = function(self, i, v)
            if v == nil then return end

            print(`SET {i} = {v}`)

            if typeof(v) == "number" then
                Variable.Set(i, get_script_context(), tostring(v))
            elseif typeof(v) == "string" then
                Variable.Set(i, get_script_context(), v)
            end

            rawset(var_env, i, v)
        end
    })

    setfenv(func, env)
    
    return function()
        print(main_script:Export(1))
    end
end
