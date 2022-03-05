module til.nodes.error;

import std.conv : to;

import til.nodes;

debug
{
    import std.stdio;
}

CommandsMap errorCommands;


class Erro : Item
{
    int code = -1;
    string classe;
    string message;
    Item object;

    this(string message, int code, string classe)
    {
        this(message, code, classe, null);
    }
    this(string message, int code, string classe, Item object)
    {
        this.object = object;
        this.message = message;
        this.code = code;
        this.classe = classe;
        this.type = ObjectType.Error;
        this.typeName = "error";
        this.commands = errorCommands;
    }

    // Conversions:
    override string toString()
    {
        string s = "Error " ~ to!string(code)
                   ~ ": " ~ message;
        if (classe)
        {
            s ~= " (" ~ classe ~ ")";
        }
        return s;
    }
}
