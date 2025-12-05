#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw

#let cuhk = super(sym.suit.spade)

#let title = [
  FireSim/FPGA - Progress Report
]

#let authors = (
  // You can use grouped affiliations with mark
  (
    name: [Milan Lagae],
    email: [],
    mark: [],
  ),
)

#let affiliations = (
  (
    name: [Institution/University Name:],
    faculty: [Faculty:],
    course: [Course:],
  ),
  (
    name: [Vrije Universiteit Brussel],
    faculty: [Sciences and Bioengineering Sciences],
    course: [Master Thesis],
  ),
)

#let conference = (
  name: [],
  short: [],
  year: [],
  date: [],
  venue: [],
)


#let doi = "/"

#show: acmart.with(
  title: title,
  authors: authors,
  affiliations: affiliations,
  conference: conference,
  doi: doi,
  copyright: "",
  // Font Size as described by the assignment
  font-size: 10pt,
)

// #set text(
//   // font: "Linux Libertine",
//   // font: "Font Awesome 6 Brands",
//   // font: "Roboto",
//   top-edge: 1em,
//   bottom-edge: 0em,
// )

#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 0.75em, below: 0.25em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.50em)


#colbreak()
= Introduction

The list of resources can be found in the section @resources. First, the attempt at using the FireSim tool in section @firesim-verilator and the following section on executing manual commands with Verilator, in section @verilator. The TLDR can be found in section @tldr.



= Resources <resources>

The following list of resources where used during the course of this research, the most important are listed below:
- https://fires.im/asplos-2023-tutorial/
  - Very good collection of slides (+ videos)!
- https://docs.fires.im/en/latest/Advanced-Usage/Debugging-in-Software/RTL-Simulation.html
- https://chipyard.readthedocs.io/en/latest/Simulation/Software-RTL-Simulation.html
- https://chipyard.readthedocs.io/en/stable/Chipyard-Basics/Configs-Parameters-Mixins.html



// #colbreak()
= TLDR <tldr>

== Firesim

Config execution using `firesim` manager:

- (re)started from example config files
- issue with sudo password & parallelism (Fabric package)
  - fixed by removing parallel annotation & setting password through ENV
- infrasetup command works for default `midasexamples_gcd`
- executing error when executing custom config: "Scala: File Not Found Exception"

== Verilator

Manual command execution using `make` & `verilator`:

- running starter config
- compiling examples binaries in `test` directory
- running simple example binaries using Verilator.


// #colbreak()
#pagebreak()
= Metasimulation <metasimulation>

This section describes on how to get metasimulation working on FireSim on a (non-AWS) local host in using the open source software simulator Verilator.


== FireSim & Verilator <firesim-verilator>


=== Installation

Installation can be done by following the tutorials on the Firesim & Chipyard documentation website, installation will take some time and the host platform is required to be a Linux x86 machine for easy of support, see website for more info.


=== Sourcing

After the installation is complete, the following commands have to be executed to source the required binaries and set the proper environment variables.

Start of with sourcing the conda environment for the correct shell, shown in @source-shell.

#figure(
  zebraw(
    lang: false,
    numbering: false,
    ```bash
    eval "$(/home/firesim/setup/miniforge3/bin/conda shell.bash hook)"
    ```,
  ),
  caption: [Extending class.],
) <source-shell>

After the shell is sourced, execute the command shown in @activating-conda.

#figure(
  zebraw(
    lang: false,
    numbering: false,
    ```bash
    conda activate base
    ```,
  ),
  caption: [Extending class.],
) <activating-conda>


Proceed to change directory to the following directory: `chipyard/sims/firesim` and source the following two files:
+ `env.sh`
+ `sourceme-manager.sh`

Sourcing the first file shouldn't give an error, but the second one will if you are running on a bare metal non-AWS f1 instance. The error message can be ignored (for now), not relevant to our configuration.

To check if the sourcing has been successful, the `which` command can be used to check if the `firesim` binary is available: `which firesim`.


=== Config

Firesim works based on the use of `*.yaml` configuration scripts. For the metasimulation use case the configuration files that are important are the following two:
- `config_runtime.yaml`
- `config_build_recipes.yaml`


These files can be copied from the `sample-backup-config` directory in the chipyard repo. The `config_runtime.yaml` file should be modified with the following values as shown in @config-runtime. Relevant sections are displayed, remaining values are the default values indicated in the documentation.

The metasimulation will be done on the same hosts we are managing firesim from. This configuration for the metasimulation slots is specified in the `config_runtime.yaml` file.

The `config_build_recipes.yaml` can stay the same as the default value with the `midasexamples_gcd` recipe specified and referenced in the `config_build_recipes.yaml` in @hw-config.

#figure(
  zebraw(
    lang: false,
    numbering: false,
    ```bash
    default_hw_config: midasexamples_gcd
    ```,
  ),
  caption: [Config parameter value.],
) <hw-config>


==== Digression

With the above files configured, and using the default configuration, the `firesim infrasetup` can be executed. Executing the command in the current configuration will display the error message shown in @parallel-sudo.

#figure(
  zebraw(
    lang: false,
    numbering: false,
    ```bash
    (...)
    2025-11-12 20:10:30,529 [flush ] [INFO ] Fatal error: Needed to prompt for a connection or sudo password (host: 192.168.17.133), but input would be ambiguous in parallel mode 2025-11-12 20:10:30,529 [flush ] [INFO ] Aborting. 2025-11-12 20:10:30,544 [flush ] [INFO ] Fatal error: One or more hosts failed while executing task 'instance_liveness'
    (...)
    ```,
  ),
  caption: [Extending class.],
) <parallel-sudo>


This error message has been tracked back to the Fabric Python library that Firesim uses to run functions in parallel on hosts.

#box(fill: blue.lighten(80%), inset: 5pt, radius: 5pt)[
  This should be revisited if time allows or a better solution is found. For now the solutions is done by modifying the Python run file as follows.
]

From the method: `instance_liveness` remove the annotation `@parallel`, in the file: `firesim_topology_with_passes` in the directory: `runtools` and add the following code shown in @python-code in the method. The code looks for an environment variable called: `FIRESIM_PWD`, which must be specified for each command that is run, and than set, so the ssh Fabric package does not complain about (sudo/parallelism) requiring a password.

#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```py
    # Set the password from retrieving a env variable.
       env.password = os.environ.get("FIRESIM_PWD")
       # Local setup, security not a consideration
       rootLogger.info("""Password: {}""".format(env.password))
    ```,
  ),
  caption: [Extending class.],
) <python-code>

*NOTE*: This is not secure, but since this is a local setup, that is not a consideration. Following firesim commands can than be executed as follows:

#figure(
  zebraw(
    lang: false,
    numbering: false,
    ```bash
    FIRESIM_PWD=<user-pwd> firesim <command>
    ```,
  ),
  caption: [Extending class.],
) <firesim-command-env>



=== Setup & Workload

After everything is setup, the `firesim infrasetup` command can be run, with the first example `gcd` there should be no errors.

#box(fill: green.lighten(80%), inset: 5pt, radius: 5pt)[
  In case of errors: a potential issue might be a missing directory named: `sim_slot_0`, in the home directory of the user used to execute the command.
]

Otherwise the connection is successful. Now we modify the config to execute a named config from the config directory. Change the `config_runtime.yaml` file and modify the `default_hw_config` parameter to specify a configuration in the `config_build_recipes.yaml`.

If that is done, the `infrasetup` command can be executed again.

*FROM this point on, file not found exception*


#box(fill: orange.lighten(60%), inset: 5pt, radius: 5pt)[
  Continuing from this point, running the config, on my end I got the file not found exception. No solution has been found at the moment of writing this.
]


// #colbreak()
== Chipyard & Verilator <verilator>

The subsection describes on how to execute Chipyard core configuration using the Verilator software simulator, by executing manual `make` commands.


The tutorial-starter-config specified in @tutorial-starter-config and used earlier will be re-used. Proceed to the `sims/verilator` directory in the chipyard repository. Executing the following command to compile your config: `make CONFIG=<config-name>`. This command should execute without a problem.

#figure(
  zebraw(
    lang: false,
    ```scala
    // Tutorial Phase 1: Configure the cores, caches
    class TutorialStarterConfig extends Config(
      // CUSTOMIZE THE CORE
      new freechips.rocketchip.rocket.WithNHugeCores(4)
      new freechips.rocketchip.subsystem.WithNBanks(4) ++
      new chipyard.config.AbstractConfig
    )
    ```,
  ),
  caption: [Modified Tutorial Starter Config],
) <tutorial-starter-config>

After the config has been successfully compiled, the binary that is to be executed must be compiled. Proceed to the `test/` directory inside the Chipyard repository.

There are different binaries that can be executed, for this use case, the `mt-hello.o` was chosen. For the list of options, the `README.md` file inside of the `test/` directory  describes on how to compile specific binaries.

Having compiled the `mt-hello.o` file to a `mt-hello.riscv` binary, it can executed on the core configuration. With the binary compiled execute the following command: `make CONFIG=<config-name> BINARY=<path-to-binary> run-binary-hex`

The last `run-binary-hex` specifies to run the binary using the fastmem option, more info is available in the documentary. Specifying the fastmem option, noticeably increases the speed of the simulation. When executing the `mt-hello.riscv` binary, the output will look like something in @firesim-hello.


#figure(
  image("assets/mt-hello.png"),
  caption: "Executing mt-hello.riscv binary, with fast memory",
) <firesim-hello>



// #colbreak()
// = Custom Tile/Cores

// *In progress*


// = Running Proper Workloads

// *In progress*



#set page(columns: 1)
== Appendix

#figure(
  zebraw(
    lang: false,
    // numbering: false,
    ```yaml

    run_farm:
      base_recipe: run-farm-recipes/externally_provisioned.yaml
      recipe_arg_overrides:
        default_platform: EC2InstanceDeployManager
        default_simulation_dir: /home/firesim
        default_fpga_db: /opt/firesim-db.json

        run_farm_hosts_to_use:
            - localhost: four_metasims_spec

        run_farm_host_specs:
            - four_metasims_spec:
                num_fpgas: 0
                num_metasims: 4
                use_for_switch_only: false


    metasimulation:
        metasimulation_enabled: true
        # vcs or verilator. use vcs-debug or verilator-debug for waveform generation
        metasimulation_host_simulator: verilator
        # plusargs passed to the simulator for all metasimulations
        metasimulation_only_plusargs: "+fesvr-step-size=128 +max-cycles=100000000"
        # plusargs passed to the simulator ONLY FOR vcs metasimulations
        metasimulation_only_vcs_plusargs: "+vcs+initreg+0 +vcs+initmem+0"

    # DOCREF START: target_config area
    target_config:
        topology: no_net_config
        no_net_num_nodes: 1
        link_latency: 6405
        switching_latency: 10
        net_bandwidth: 200
        profile_interval: -1

        default_hw_config: midasexamples_gcd
        plusarg_passthrough: ""

    (...)
    ```,
  ),
  caption: [Config Runtime File],
) <config-runtime>
