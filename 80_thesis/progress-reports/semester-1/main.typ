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

The list of resources can be found in the section @resources. First trying to run using the FireSim tool in section @firesim-verilator and the last section on executing manual commands in section @verilator.


= Resources <resources>

The following list of resources where used during the course of this research, the most important are listed below:
- https://fires.im/asplos-2023-tutorial/
  - Very good collection of slides (+ videos)!
- https://docs.fires.im/en/latest/Advanced-Usage/Debugging-in-Software/RTL-Simulation.html
- https://chipyard.readthedocs.io/en/latest/Simulation/Software-RTL-Simulation.html
- https://chipyard.readthedocs.io/en/stable/Chipyard-Basics/Configs-Parameters-Mixins.html


// #colbreak()
#pagebreak()
= Metasimulation <metasimulation>

This is about getting metasimulation working in FireSim using the open source simulator Verilator.


== FireSim & Verilator <firesim-verilator>


=== Installation

Installing can be done by following the tutorials on the firesim & chipyard documentation website, installation will take some time and the host platform is required to be a Linux x86 machine for easy of support.


=== Sourcing

After the installation the following commands have to be executed to source the required binaries and set proper enviornment variables.

First start of with sourcing the conda enviroment for the correct shell, shown in @source-shell.

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

After the shell is sourced execute the command shown in @activating-conda.

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


Proceed to change directory to the folllowing directory: `chipyard/sims/firesim` and source the following two files:
+ `env.sh`
+ `sourceme-manager.sh`

Sourcing the first file shouldn't give an error, but the second one will if you are running on a baremetal non-aws f1 instance. The error message can be ignored (for now), not relevant to our configuration.

To check if the sourcing has been successful, the `which` can be used to check if the `firesim` binary is available: `which firesim`.


=== Config

Firesim works based on the use of `*.yaml` configuration scripts. For the metasimulation use case the configuration files that are important are the following two:
- `config_runtime.yaml`
- `config_build_recipes.yaml`


These files can be copied from the `sample-backup-config` directory in the chipyard repo. The `config_runtime.yaml` file should be modified with the following section of code:

*INSERT CODE*


The metasimulation will be done on the same hosts we are managing firesim from. This configuration for the metasimulation slots must be specified in the following file: *ADD*. And can than be referenced in the `config_runtime.yaml` file.


==== Digression

With the above files set, and using the default configuration, the `firesim infrasetup` can be executed. Executing the command in the current configuration will display the error message shown in @paralel-sudo.

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
) <paralel-sudo>


This error message has been tracked back to the Fabric Python library that Firesim uses to run functions in parallel on hosts and local setup.

This should be revisited if time allows or a better solution is found. For now the solutions is done by modifying the python run file as follows.


From the method: `instance_liveness` remove the annotation `@parallel`, in the file: `firesim_topology_with_passes` and directory: `runtools` and add the following code in @python-code in the method. The code looks for an environemnt variable called: `FIRESIM_PWD`, which must be specified for each command that is run, and than set, so the ssh Fabric package does not complain about (sudo/parallism) requiring a password.

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




==== Specifing Metasim Slots

This name must match the name of the config defined, which specifies the numbers of cores,memory, abstract config, .. .

*CONTINUE*

For each run configuration a chip configuration must be specified, the most important value of the config, is the name of the config in the `config` directory.



=== Setup & Workload

After everything is setup, the `firesim infrasetup` command can be run, with the first example `gcd` there should be no errors, and the following kind of output should be visible:

*ADD*

If that is the case the connection is successful. Now we modify the config to execute a named config from the config directory. Change the *ADD* file to the following:

*ADD*


If that is done, we can run the infrasetup command again.

*FROM this point, file not found exception*

Contininuing from this point, running the config, on my end I got the java file not found exception. No solution has been found at the moment of writing this.


#colbreak()
== Chipyard & Verilator <verilator>


Since FireSim makes use of Verilator under the hood, I decided to perform manual command executions.

We will make use of the config we specified earlier. Proceed to the `sims/verilator` directory in the chipyard repository. Executing the following command to compile your config: `make CONFIG=<config-name>`. This command should execute without a problem. An example of this command can be found below:

*ADD IMAGE*

After this we can proceed to run a binary, before we can run an RISC-V binary, we must first compile a binary to run. Go into the `test/` directory inside the Chipyard repository. You can decide which binary you want to run, to compile assembly code, read the `README.md` file inside of the directory, it describes on how to compiler all/or a specific binary. I will assume you compiled the `mt-hello.o` file to a `mt-hello.riscv` binary.

With the binary compiled proceed to execute the following command: `make CONFIG=<config-name> BINARY=<path-to-binary> run-binary-hex`

The last `run-binary-hex` specifies to run the binary using the fastmem option, more infor is available in the documentary. Specifying the fastmem option, noticably increases the speed of the simulation. When executing the `mt-hello.riscv` binary, the output will look like something in @firesim-hello, which executes the non multi-threaded version of the binary.


#figure(
  image("/assets/Pasted image 20251120115030.png"),
  caption: "Executing hello.riscv binary, with slow memory",
) <firesim-hello>




= Custom Tile/Cores

*In progress*


= Running Proper Workloads

*In progress*
