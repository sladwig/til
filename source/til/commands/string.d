module til.commands.string;

import std.array;
import std.regex : matchAll;
import std.string : indexOf;

import til.nodes;


// Commands:
static this()
{
    stringCommands["extract"] = (string path, CommandContext context)
    {
        String s = context.pop!String();

        if (context.size == 0) return context.push(s);

        auto start = context.pop().toInt();
        if (start < 0)
        {
            start = s.repr.length + start;
        }

        auto end = start + 1;
        if (context.size)
        {
            end = context.pop().toInt();
            if (end < 0)
            {
                end = s.repr.length + end;
            }
        }

        context.exitCode = ExitCode.CommandSuccess;
        context.push(new String(s.repr[start..end]));
        return context;
    };
    stringCommands["length"] = (string path, CommandContext context)
    {
        auto s = context.pop!String();
        context.exitCode = ExitCode.CommandSuccess;
        return context.push(s.repr.length);
    };
    stringCommands["split"] = (string path, CommandContext context)
    {
        auto s = context.pop!string;
        if (context.size == 0)
        {
            auto msg = "`" ~ path ~ "` expects two arguments";
            return context.error(msg, ErrorCode.InvalidSyntax, "");
        }
        auto separator = context.pop!string;

        SimpleList l = new SimpleList(
            cast(Items)(s.split(separator)
                .map!(x => new String(x))
                .array)
        );

        context.push(l);
        context.exitCode = ExitCode.CommandSuccess;
        return context;
    };
    stringCommands["join"] = (string path, CommandContext context)
    {
        string joiner = context.pop!string();
        if (context.size == 0)
        {
            auto msg = "`" ~ path ~ "` expects at least two arguments";
            return context.error(msg, ErrorCode.InvalidSyntax, "");
        }
        foreach (item; context.items)
        {
            if (item.type != ObjectType.SimpleList)
            {
                auto msg = "`" ~ path ~ "` expects a list of SimpleLists";
                return context.error(msg, ErrorCode.InvalidSyntax, "");
            }
            SimpleList l = cast(SimpleList)item;
            context.push(
                new String(l.items.map!(x => to!string(x)).join(joiner))
            );
        }
        context.exitCode = ExitCode.CommandSuccess;
        return context;
    };
    stringCommands["find"] = (string path, CommandContext context)
    {
        string needle = context.pop!string();
        // TODO: make the following code template:
        if (context.size == 0)
        {
            auto msg = "`" ~ path ~ "` expects two arguments";
            return context.error(msg, ErrorCode.InvalidSyntax, "");
        }
        foreach(item; context.items)
        {
            string haystack = item.toString();
            context.push(haystack.indexOf(needle));
        }
        context.exitCode = ExitCode.CommandSuccess;
        return context;
    };
    stringCommands["matches"] = (string path, CommandContext context)
    {
        string expression = context.pop!string();
        if (context.size == 0)
        {
            auto msg = "`" ~ path ~ "` expects two arguments";
            return context.error(msg, ErrorCode.InvalidSyntax, "");
        }
        string target = context.pop!string();

        SimpleList l = new SimpleList([]);
        foreach(m; target.matchAll(expression))
        {
            l.items ~= new String(m.hit);
        }
        context.push(l);

        context.exitCode = ExitCode.CommandSuccess;
        return context;
    };
    stringCommands["range"] = (string path, CommandContext context)
    {
        /*
        range "12345" -> 1 , 2 , 3 , 4 , 5
        */
        class StringRange : Item
        {
            string s;
            int currentIndex = 0;
            ulong _length;

            this(string s)
            {
                this.s = s;
                this._length = s.length;
            }
            override string toString()
            {
                return "StringRange";
            }
            override CommandContext next(CommandContext context)
            {
                if (this.currentIndex >= this._length)
                {
                    context.exitCode = ExitCode.Break;
                }
                else
                {
                    auto chr = this.s[this.currentIndex++];
                    context.push(to!string(chr));
                    context.exitCode = ExitCode.Continue;
                }
                return context;
            }
        }

        string s = context.pop!string();
        context.push(new StringRange(s));
        context.exitCode = ExitCode.CommandSuccess;
        return context;
    };
}
