import Foundation

struct Arguments {
    var cronMode: Bool = true
    var verbose: Bool = false
    var help: Bool = false
}

func printUsage() {
    let usage = """
    Usage: MAGDVMobileReviewsBot [options]
    Options:
      --cron             Run in a CRON mode (run once, then exit) [default]
      --verbose          Enable verbose mode
      --help             Display this help message
    
    Default config.json location is ./data/config.json
    """
    print(usage)
}

func parseArguments(_ args: [String]) -> Arguments {
    var arguments = Arguments()

    var index = 1
    while index < args.count {
        let arg = args[index].lowercased()
        switch arg {
        case "--cron":
            arguments.cronMode = true
        case "--verbose":
            arguments.verbose = true
        case "--help":
            arguments.help = true
        default:
            print("Unknown option: \(arg)")
            printUsage()
            exit(1)
        }
        index += 1
    }

    return arguments
}

let arguments = parseArguments(CommandLine.arguments)

if arguments.help {
    printUsage()
    exit(0)
}

if arguments.verbose {
    print("Verbose mode is enabled.")
}

#if DEBUG
Config.verbose = true
#else
Config.verbose = arguments.verbose
#endif

Config.load()

if arguments.cronMode {
    ReviewsNotifyTask.run()
}
