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

    Get: (self: Variable) -> string;
    Set: (self: Variable, value: string) -> ();
    Increase: (self: Variable, by: string) -> ();
    Decrease: (self: Variable, by: string) -> ();
    Multiply: (self: Variable, by: string) -> ();
    Divide: (self: Variable, by: string) -> ();
    Round: (self: Variable) -> ();
    Floor: (self: Variable) -> ();
    SetRandom: (self: Variable, min: string, max: string) -> ();
    SetToTextFromInput: (self: Variable, globalid: number) -> ();
}

type Variable = typeof(setmetatable({} :: {
    name: string,
    script_obj: ScriptObj
}, {} :: VariableImpl))

local Variable: VariableImpl = {} :: VariableImpl
Variable.__index = Variable

function Variable:Get()
    return "{"..self.name.."}"
end
function Variable:Set(value)
    table.insert(self.script_obj.data, {
        id = "11";
        text = {
            "Set variable",
            {
                value = self.name;
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
function Variable:Increase(by)
    table.insert(self.script_obj.data, {
        id = "12";
        text = {
            "Increase",
            {
                value = self.name;
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
function Variable:Decrease(by)
    table.insert(self.script_obj.data, {
        id = "13";
        text = {
            "Subtract",
            {
                value = self.name;
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
function Variable:Multiply(by)
    table.insert(self.script_obj.data, {
        id = "14";
        text = {
            "Multiply",
            {
                value = self.name;
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
function Variable:Divide(by)
    table.insert(self.script_obj.data, {
        id = "15";
        text = {
            "Divide",
            {
                value = self.name;
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
function Variable:Round()
    table.insert(self.script_obj.data, {
        id = "16";
        text = {
            "Round",
            {
                value = self.name;
                t = "string";
            }
        }
    })
end
function Variable:Floor()
    table.insert(self.script_obj.data, {
        id = "17";
        text = {
            "Floor",
            {
                value = self.name;
                t = "string";
            }
        }
    })
end
function Variable:SetRandom(min, max)
    table.insert(self.script_obj.data, {
        id = "27";
        text = {
            "Set",
            {
                value = self.name;
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
function Variable:SetToTextFromInput(globalid)
    table.insert(self.script_obj.data, {
        id = "30";
        text = {
            "Set",
            {
                value = self.name;
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
    IfEqual: (self: ScriptObj, a: string, b: string, callback: () -> ()) -> ();
    IfNotEqual: (self: ScriptObj, a: string, b: string, callback: () -> ()) -> ();
    IfGreater: (self: ScriptObj, a: string, b: string, callback: () -> ()) -> ();
    IfLower: (self: ScriptObj, a: string, b: string, callback: () -> ()) -> ();

    Repeat: (self: ScriptObj, times: string, callback: () -> ()) -> ();
    RepeatForever: (self: ScriptObj, callback: () -> ()) -> ();

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

    CreateVariable: (self: ScriptObj, name: string) -> Variable;
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
function ScriptObj:IfEqual(a, b, callback)
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

    callback(self)

    table.insert(self.data, {
        id = "25";
        text = {"end"};
    })
end
function ScriptObj:IfNotEqual(a, b, callback)
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

    callback(self)

    table.insert(self.data, {
        id = "25";
        text = {"end"};
    })
end
function ScriptObj:IfGreater(a, b, callback)
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

    callback(self)

    table.insert(self.data, {
        id = "25";
        text = {"end"};
    })
end
function ScriptObj:IfLower(a, b, callback)
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

    callback(self)

    table.insert(self.data, {
        id = "25";
        text = {"end"};
    })
end

function ScriptObj:Repeat(times, callback)
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

    callback(self)

    table.insert(self.data, {
        id = "25";
        text = {"end"};
    })
end
function ScriptObj:RepeatForever(callback)
    table.insert(self.data, {
        id = "23";
        text = {
            "Repeat forever"
        }
    })

    callback(self)

    table.insert(self.data, {
        id = "25";
        text = {"end"};
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

function ScriptObj:CreateVariable(name)
    return setmetatable({
        name = name;
        script_obj = self;
    }, Variable)
end

---------------------
----- CatScript -----
---------------------
type CatScriptImpl = {
    __index: CatScriptImpl;
    new: () -> CatScript;
    Export: (self: CatScript, globalid: number?) -> string;

    Loaded: (self: CatScript, callback: (ScriptObj) -> ()) -> ();
    ButtonPressed: (self: CatScript, globalid: number, callback: (ScriptObj) -> ()) -> ();
    ButtonHovered: (self: CatScript, globalid: number, callback: (ScriptObj) -> ()) -> ();
    KeyPressed: (self: CatScript, key: string, callback: (ScriptObj) -> ()) -> ();
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
function CatScript:Loaded(callback)
    local script_data = ScriptObj.new()
    callback(script_data)

    table.insert(self.data, {
        id = "0";
        text = {};
        actions = script_data.data;
    })
end
function CatScript:ButtonPressed(globalid, callback)
    local script_data = ScriptObj.new()
    callback(script_data)

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
        actions = script_data.data;
    })
end
function CatScript:ButtonHovered(globalid, callback)
    local script_data = ScriptObj.new()
    callback(script_data)

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
        actions = script_data.data;
    })
end
function CatScript:KeyPressed(key, callback)
    local script_data = ScriptObj.new()
    callback(script_data)

    table.insert(self.data, {
        id = "2";
        text = {
            "When",
            {
                value = key
            },
            "pressed..."
        };
        actions = script_data.data;
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

return CatScript