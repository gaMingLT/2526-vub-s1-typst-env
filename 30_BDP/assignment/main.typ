#import "@preview/clean-acmart:0.0.1": acmart, acmart-ccs, acmart-keywords, acmart-ref, to-string

// Code Blocks
#import "@preview/zebraw:0.5.2": *
#show: zebraw
// #show: zebraw.with(..zebraw-themes.zebra)

#import "@preview/lilaq:0.5.0" as lq

#let cuhk = super(sym.suit.spade)

#let title = [
  Project: Traffic Prediction
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
    course: [Big Data Processing],
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
  font-size: 11pt,
)

// #set text(font: "Source Sans 3", weight: "regular", size: 10pt)


// TODO: Fix heading font's
// #show heading.where(
//   level: 1,
// ): it => text(
//   // font: "Source Code Pro",
//   font: "Source Sans 3",
//   // size: 2pt,
//   weight: "bold",
//   style: "normal",
//   it.body,
// )


#outline()

// Modify the heading spacing above and below!
#show heading.where(): set block(above: 1em, below: 0.75em)

// Modify the spacing above a figure (codeblock), so the language annotation does not conflict with text.
#show figure.where(): set block(above: 1em, below: 0.50em)

// TODO: Look at the assignment for which questions need to be discussed.

#colbreak()
= Intro

This report will discuss an implementation for the assignment "Project: Traffic Prediction" for the course: Big Data Processing. First the implementation itself will be discussed in section @implementation. Following that, answers to the required questions in section @discussion. And lastly a small section on performance benchmarks in section @benchmarks.


= Implementation <implementation>

This section will discuss the implementation (code) for the project. Full project code can be found in the associated Apache Spark project or small snippets will be placed in the text or larger ones in the Appendix section @appendix.


== Overview

All the code can be found in the `traffic` package of the `bdp-traffic` folder. The `traffic` package consists of the following files:
- `Traffic.scala`
- `TrafficLoader.scala`
- `TrafficJoiner.scala`
- `TrafficTimeSeries.scala`
- `TrafficTransformer.scala`
- `TrafficPredictor.scala`

The order of the file is in which they are structured & applied to the input. Each file also has it's own logger variable set, which is used for logging, for this the `build.sbt` file was modified with an additional package. Each step/class in the pipeline receives a reference to the `SparkSession` by the `spark` variable.


== `Traffic.scala`

This is the file that is executed when the project is ran, it executes the different steps (files) in a kind of pipeline. The complete pipeline can be seen in listing: @execution-pipeline.


#figure(
  image("images/BDP-Flow.pdf"),
  caption: [Execution Pipeline],
) <execution-pipeline>


== Loader

The loader or `TrafficLoader.scala` file is responsible for loading the correct data set files. For this 3 different methods are created for each type of file: `loadVolume`, `loadSpeed` and `loadFeatures`. Loading the correct file is done based on the `dataset` value which is a enum, as shown in listing

#figure(
  zebraw(
    numbering: false,
    lang: false,
    ```scala
    object DataSet extends Enumeration {
      type DataSet = Value

      val L_Tiny, M_Tiny_Select = Value
    }
    ```,
  ),
)

This way, if different datasets are required to be used/tested this can be easily extended. In the `Traffic.scala` file, each dataframe is seperately loaded and stored in a dataframe.


== Joiner

In this step of the pipeline the 3 dataframes are unpivotted & joined together to create one big dataframe, for application of time-series values in next step.

=== Features <features>

This step in the pipeline is responsible for joining the different data files in one melted dataframe.

First start by adding a `id` column to the features dataframe. For this accessing the `rdd` of the dataframe. This is done using a `zipWithIndex` and a `map`, doing it this way ensures a correct assigning of id's over partitions @spark_apache_id @stack_overflow_id. After adding the id column, the rdd is transformed back into a dataframe.

=== Speed & Volume

The following operations are identical for both dataframes: `speed` & `volume`. Each dataframe is unpivotted, from a wide format to a long format. For this the sql method `stack` is used.

After the respective dataframe is unpivotted, the `node` column is updated to a `int` type, by removing the `node_` from the column name and casting it to an `int` value, so it is supported in a Vector Assembler.


=== Joining

The speed & volume dataframes are joined on the `node` & `timestamp` columns, for an `inner` join operation. From the features dataframe, a select list of columns is selected bassed on assumption of relevancy for prediction model.

Finally the selected features dataframe is joined with the earlier speed & volume dataframe on `node` column value.


== Time-Series

This section will describe which time-series features where added to the dataframe.

=== Lag

For both speed & volume, the following lag features were added:
- half hour/ 30 minutes = 6 rows
- 1 hour / 60 minutes = 12 rows
- 1 day / 1440 minutes = 288 rows

The default value chosen for the lag is $0$, since this value works better with the prediction models in `mllib`.

=== Window

A rolling window of half an hour and 1 hour was added for both the speed & volume metric.

At the end of the updated dataframe, the operation to replaced all `null` values with zero is applied, prevents any issues with prediction model is next steps.


== Transformer

This step of the pipeline will apply the Vector Assembler to the selected columns to create a `features` column, so the model can be trained on it.

The Vector Assembler is first applied to a sequences of selected columns, with the output name of the column being: `features`. After the features column is generated the additional rows for each node is created.

For this first retrieve the latest timestamp from the dataframe and parse into correct Java type. Using a map, create a dataframe consisting of 6 rows and one column named: `timestamp`. Proceed to select the columns `node` & `features` and apply the distinct operation.

Using `crossJoin`, with the nodes dataframe & timestamp dataframe, a dataframe with for each relation of node & feature value 6 additional timestamp rows are created. Also add the `speed` column with default value of $0$.

From the dataframe vector, select the columns: `timestamp`, `node`, `speed` and `features`. Proceed to apply the `unionByName` operation on this dataframe and the previously generated dataframe. This concludes the steps for preparing the data for model prediction.

Return the final dataframe and largest timestamp from the original data as a tuple, will be used in the prediction step.


== Predictor

The prepared data can now be split in training data and 'test' data, this is done by filter on the value of the timestamp column. All rows with an equal of lower timestamp value are training data, while larger timestamps are the prediction data, that was generated in the previous step.

The `RandomForestRegressor` model is created, with the label column: `speed` & features column: `features`. Other values are left default. The model is fitted on the training dataframe (`trainDF`). The generated model is writen to file as described in the assignment.

Lastly, the model is applied to the prediction dataframe (`predictionDF`) to predict future speeds.

== Output

The result of the prediction is returned to the `Traffic.scala` file. The generated prediction data (`predictions`) is passed to the `writeFile` method, which is responsible for printing and (maybe) writing output to a file.

The generated data frame is iterated and the values for each timestamp are writen per line, with values being the speed for each node. If required, a boolean: `file` can be set to write the output to a file.

= Discussion <discussion>


== Question 1

*Question*: Have you persisted some of your intermediate results? Why could persisting your data in memory be helpful for this pipeline?

Based on the benchmarks performed in section @benchmarks, the answer to this question, is that persisting data for this pipeline has a negative effect. Possible reasons for this is the fact, that the used dataset is quit small in comparison to the full dataset(s) available. A proper conclusion cannot be made without further testing.


== Question 2

*Question 2:* In which parts of your implementation have you used partitioning? Did this impact perfor
mance? If so,why?

// TODO: Add!
*TODO*


== Question 3

*Question 3*: Which datastructure(s) does your implementation use: RDDs,DataFrames,orDatasets? Please motivate your choice.

The implementation makes mostly use of the dataframes, since these, as seen in clase have the best performance optimization enabled under the hood. For reasoning on why RDD's where used in one specific section please see: @features.

== Question 4

*Question 4:*  Which predictive algorithm did you use and why?

The chosen predicate model is: `RandomForestRegressor`, since this is what was recommend in the FAQ section of the assignment. No time was available for testing other models.


= Benchmarks <benchmarks>

For all benchmarks, 4 runs where done, the first one was considered a dry run and proceeding 3, the average was taken.

For the types of benchmarks ran on each host on the local context, both used the same provided dataset:
- Type 1: No cache/persist & other default settings
- Type 2: Cache & other default settings
- Type 3: Persist & other default settings


== Specifications

=== Macbook

#table(
  columns: (1fr, 1fr),
  [*Part*], [*Value*],
  [CPU], [M2 Pro],
  [RAM], [16GB],
  // TODO: Add
  [OS], [*ADD*],
)


=== Desktop


#table(
  columns: (1fr, 1fr),
  [*Part*], [*Value*],
  [CPU], [Ryzen 9 5950X],
  [RAM], [64GB],
  // TODO: Add
  [OS],
  [Versie	10.0.22631 Build 22631
  ],
)


== Results

#let xs = (0, 1, 2)
#let labels = ("None", "Cache", "Persist")

#let macbook = (12, 21.33, 22.667)
#let desktop = (16, 27, 26.67)

#lq.diagram(
  title: [Performance],
  xlabel: "Type",
  ylabel: "Time (Seconds)",

  xaxis: (ticks: xs.zip(labels)),

  lq.plot(xs, macbook, mark: "s", label: [Macbook Pro]),
  lq.plot(xs, desktop, mark: "s", label: [Desktop]),
)





#set page(columns: 1)
= Appendix <appendix>


#bibliography("references.bib")
