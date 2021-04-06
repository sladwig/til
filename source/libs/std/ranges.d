module til.std.ranges;

import std.conv;
import std.experimental.logger;

import til.escopo;
import til.nodes;
import til.ranges;


class Range : InfiniteRange
{
    int start = 0;
    int limit = 0;
    int step = 1;
    int current = 0;

    this(int limit)
    {
        this.limit = limit;
    }
    this(int start, int limit)
    {
        this(limit);
        this.current = start;
        this.start = start;
    }
    this(int start, int limit, int step)
    {
        this(start, limit);
        this.step = step;
    }

    override string toString()
    {
        return
            "range("
            ~ to!string(start)
            ~ ","
            ~ to!string(limit)
            ~ ")";
    }

    override void popFront()
    {
        current += step;
    }
    override ListItem front()
    {
        return new Atom(current);
    }
    override bool empty()
    {
        return (current >= limit);
    }
    override Range save()
    {
        auto x = new Range(limit);
        x.current = current;
        return x;
    }
}

// The module:
class Ranges : Escopo
{
    string name = "ranges";

    Result cmd_zeroTo(NamePath path, Args arguments)
    {
        auto limit = arguments.consume().asInteger;
        tracef(" range.limit:%s", limit);

        auto range = new Range(limit);
        return new SubList(range);
    }
    Result cmd_range(NamePath path, Args arguments)
    {
        auto start = arguments.consume().asInteger;
        tracef(" range.start:%s", start);
        auto limit = arguments.consume(0).asInteger;
        tracef(" range.limit:%s", limit);

        if (limit == 0)
        {
            // zero_to...
            limit = start;
            start = 0;
        }
        else if (limit <= start)
        {
            throw new Exception("Invalid range");
        }

        int step = arguments.consume(1).asInteger;
        tracef(" range.step:%s", step);

        auto range = new Range(start, limit, step);
        return new SubList(range);
    }

    override void loadCommands()
    {
        /*
        import std.ranges as range
        range.zero_to 10
        */
        this.commands["zero_to"] = &cmd_zeroTo;
        this.commands["MAIN"] = &cmd_range;
    }
}
