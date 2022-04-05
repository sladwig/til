module til.scheduler;

import core.thread.fiber;
import std.algorithm : filter;
import std.algorithm.searching : canFind;
import std.array : array;

import til.nodes;
import til.process;


class Scheduler
{
    Process[] processes = null;
    Process[] activeProcesses = null;

    this()
    {
        this([]);
    }
    this(Process process)
    {
        this([process]);
    }
    this(Process[] processes)
    {
        foreach(process; processes)
        {
            add(process);
        }
    }

    Pid add(Process process)
    {
        process.scheduler = this;
        processes ~= process;
        activeProcesses ~= process;
        return new Pid(process);
    }

    // TODO: clean up: remove finished processes from .processes.
    void reset()
    {
        processes = [];
        activeProcesses = [];
    }

    uint run()
    {
        uint activeCounter = 0;
        Process[] finishedProcesses;

        foreach(process; activeProcesses)
        {
            if (process.state == Fiber.State.TERM)
            {
                finishedProcesses ~= process;
                continue;
            }
            activeCounter++;
            process.call();
        }

        // Clean up finished processes:
        if (finishedProcesses.length != 0)
        {
            activeProcesses = array(
                activeProcesses.filter!(item => !finishedProcesses.canFind(item))
            );
        }

        return activeCounter;
    }

    Context[] failingContexts()
    {
        Context[] contexts;
        foreach(process; processes)
        {
            if (process.context.exitCode == ExitCode.Failure)
            {
                contexts ~= process.context;
            }
        }
        return contexts;
    }

    void yield()
    {
        Fiber.yield();
    }
}
