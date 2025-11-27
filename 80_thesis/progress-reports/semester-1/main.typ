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



= Introduction




#colbreak()
= Metasimulation

This is about getting metasimulation working in FireSim using the open source simulator Verilator.


== FireSim & Verilator


== Installation

Installing can be done by following the tutorials on the firesim & chipyard documentation website, installation will take some time and the host platform is required to be a Linux x86 machine for easy of support.


== Config

Firesim works based on the use of `*.yaml` configuration scripts. For the metasimulation use case the configuration files that are important are the following two:
- *ADD*
- *ADD*


These files can be copied from the `examples` directory in the chipyard repo.

The `config_runtime.yaml` file should be modified with the following section of code:

*INSERT CODE*


The metasimulation will be done on the same hosts we are managing firesim from. This configuration for the metasimulation slots must be specified in the following file: *ADD*. And can than be reference in the `config_runtime.yaml` file.

For each run configuration a chip configuration must be specified, the most important value of the config, is the name of the config in the `config` directory.

This name must match the name of the config defined, which specifies the numbers of cores,memory, abstract config, .. .


Due to configuration/setup at home some small modifications had to be made to the python file executing the firesim commands, this file is named: *ADD* and can be found in: *ADD*.

=== Digression:

From the method: *ADD* remove the annotation *ADD* and add the following code in the method, looking for an environemnt variable called: *ADD*, which must be specified for each command that is run, and than set, so the ssh Fabric package does not complain about sudo/parallism requiring a password.


== Setup & Workload

After everything is setup, the `firesim infrasetup` command can be run, with the first example `gcd` there should be no errors, and the following kind of output should be visible:

*ADD*

If that is the case the connection is successfull. Now we modify the config to execute a named config from the config directory. Change the *ADD* file to the following:

*ADD*


If that is done, we can run the infrasetup comamnd again.

*FROM this point, file not found exception*



#colbreak()
== Chipyard & Verilator


Since the
