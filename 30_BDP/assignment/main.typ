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

This report will discuss an implementation for the assignment "Project: Traffic Prediction" for the course: Big Data Processing. First, the implementation itself will be discussed in section @implementation. Following that, answers to the required questions in section @discussion. And lastly, a small section on performance benchmarks in section @benchmarks.


= Implementation <implementation>

This section will discuss the implementation (code) for the project. Full project code can be found in the associated Apache Spark project or small snippets will be placed in the text or larger ones in the Appendix section @appendix.


== Overview

All the files can be found in the `traffic` package of the `bdp-traffic` folder. The `traffic` package consists of the following files:
- `Traffic.scala`
- `TrafficLoader.scala`
- `TrafficJoiner.scala`
- `TrafficTimeSeries.scala`
- `TrafficTransformer.scala`
- `TrafficPredictor.scala`

The files are structurd in the ordered in which they are applied to the input.Each file also has its own logger variable set, which is used for logging. For this, the `build.sbt` file was modified with an additional package. Each class in the pipeline receives a reference to the `SparkSession` by the `spark` variable.


== `Traffic.scala`

This is the file that is executed when the project is ran. It executes the different steps (files) in pipeline manner. The complete execution pipeline can be seen in listing: @execution-pipeline.


#figure(
  image("images/BDP-Flow.pdf"),
  caption: [Execution Pipeline],
) <execution-pipeline>


== Loader


The loader or `TrafficLoader.scala` file is responsible for loading the correct data set files. For this 3 different methods are created for each type of file: `loadVolume`, `loadSpeed` and `loadFeatures`. Loading the correct file is done based on the `dataset` value which is an enum, as shown in listing

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

This way, if different datasets are required to be tested this can be easily extended. In the `Traffic.scala` file, each dataframe is seperately loaded and stored in a dataframe.


== Joiner

In this step of the pipeline, the 3 dataframes are unpivotted & joined together to create one big dataframe, for application of time-series values in next step.

=== Features <features>

This step in the pipeline is responsible for joining the different data files in one melted dataframe.

First, start by adding an `id` column to the features dataframe. For this the RDD of the dataframe is accessed. This is done using a `zipWithIndex` and a `map`. This ensures a consisting numerically ordered id, over different partitions @spark_apache_id @stack_overflow_id. After adding the id column, the RDD is transformed back into a dataframe.

=== Speed & Volume

The following operations are identical for both dataframes: `speed` & `volume`. Each dataframe is unpivotted, from a wide format to a long format. For this, the sql method `stack` is used.

After the respective dataframe is unpivotted, the `node` column is updated to a `int` type, by removing the `node_` from the column name and casting it to an `int` value. This allows the column to be used as a feature when applying the Vector Assembler.


=== Joining

The speed & volume dataframes are joined on the `node` & `timestamp` columns, for an `inner` join operation. From the features dataframe, a select list of columns is selected based on assumption of relevancy for the prediction model.

Finally, the selected features dataframe is joined with the earlier speed & volume dataframe on `node` column value.


== Time-Series

This section will describe which time-series features were added to the dataframe.

=== Lag

For both speed & volume, the following lag features were added:
- half hour/ 30 minutes = 6 rows
- 1 hour / 60 minutes = 12 rows
- 1 day / 1440 minutes = 288 rows

The default value chosen for the lag is $0$, since this value works better with the prediction models in `mllib`.

=== Window

A rolling window of half an hour and 1 hour was added for both the speed & volume metric.

At the end of the updated dataframe, the operation to replace all `null` values with zero is applied, this prevents any issues with the prediction model in subsequent steps.


== Transformer

This step of the pipeline will apply the Vector Assembler to the selected columns to create a `features` column to the given dataframe. This done once for the historical training data and multiple times during the prediction phase for the test data.

For this reason, there are $2$ different transform methods contained in the class.


=== Training Data 

Preparing the given dataframe for the training phase is done with the `InitTransform` method. The features column is generated by applying the `VectorAssembler` to the selected list of columns marked as featured. The resulting dataframe is called: `transformedDF`.

To prematurely optimize, the historical dataframe is selected for the most important values. To start with, the training dataframe (`trainingDataDF`) is created, by selecting the columns: `node`, `timestamp`, `speed`, `volume` and `features`. 

Furthermore, the combination of each node and it's selected list of static features is selected from the `transformedDF` dataframe, to which the `distinct` operation is applied, creating the unqique combination of each node with it static features (`nodeFeaturesDF`).

To further reduce the number of rows required to be kept in memory during the prediction phase, a select number of rows, 287 to be specific is selected from the `transformedDF` by the `takeHistory` method. The number of rows is specific to the maximum number of rows requires for the time-series step. Shifting the rows by 1 day (288 rows).

Taking the 287 latest row for *each* node, is done by first generating a Window, which is parititioned on the `node` column and ordered descendingdly (latest timestamp first) on the timestamp. Selecting the correct rows is done by adding a new column `rn`, to which the previously made `Window` is used for generating the correct row number. The rows are than filtered on the column number, dropping any for which the following holds: $"rn" > 287$. Lastly, a select is performed to select the required list of columns, following the transformation. 


Following the transformation of the input data, and generated `baseDataDF` dataframe, the latest timestamp in the historicaldata is retrieved.

A tuple of 4 values is returned from the prepartion transformation step: `baseDataDF`, `trainingDataDF`, `nodeFeaturesDF`, `endTime`.


=== Predicting Data

For the transformation step during the prediction phase of the pipeline, the `VectorAssembler` is again applied on the input dataframe and `features` column is generated. A single value: `transformedDF` is returned.



== Predictor

A flowchart visualiation of the steps taken during predictor phasse of the pipeline can be found in @prediction-flowchart, a legend is available in @prediction-legend.

#figure(
  image(
    "images/BDP-Prediction.pdf"
),
  caption: [Prediction Step Flowchart]
) <prediction-flowchart>


The `RandomForestRegressor` model is created, with the label column: `speed` & features column: `features`. Other values are left default. The model is fitted on the training dataframe (`trainingDF`). The generated model is written to file as described in the assignment.

From the given latest timestamp (`endTime`), 6 future values are generated. The list of future timestamps is iterated.

During iteration, the additional rows are created by adding the `timestamp`, `speed` and `volume` columns to the `nodeFeaturesDF`. The future rows are added to the historical dataframe (`dataDF`) by using `unionByName`.  The time-series columns are created by applying the `addTimeSeries` method on the dataframe. Once the time-seriese columns have been added, the features columns is generated.

With the prepartion phase complete, the prediction can be done by applying the `transformedDF` to the `rf_model`. The result dataframe contains a `prediction` column, containing the prediction for the speed of each node on that particular timestamp.

To include the predicted speed value in further prediction of speed for time-series features, the rows containing the current `timestamp` have their speed (originally $0$) set to the value in the `prediction` column (predicted value).

Lastly, the historically data is updated, by removing one row from the original dataset and including the new row with predicted speed, by applying the `takeHistory` method on the  `updateDF` dataframe. The result of this application is put in the mutable variable: `dataDF`, which is continuously updated during the iteration.


After the predictions, the predicted rows are selected by filtering out all the rows that have a timestamp that is lower than the `endtime`. On the `predictions` dataframe, the `unpivot` operation is applied, so the dataframe is in correct format for displaying information in the terminal.


== Output

The result of the prediction is returned to the `Traffic.scala` file. The generated prediction data (`predictions`) is passed to the `writeFile` method, which is responsible for printing and (maybe) writing output to a file.

The generated data frame is iterated and the values for each timestamp are written per line, with values being the speed for each node. If required, a boolean: `file` can be set to write the output to a file.

#colbreak()
= Discussion <discussion>


== Question 1

*Question*: Have you persisted some of your intermediate results? Why could persisting your data in memory be helpful for this pipeline?

Based on the benchmarks performed in section @benchmarks, the answer to this question is, that persisting data for this pipeline has a negative effect. Possible reasons for this is the fact, that the used dataset is quit small in comparison to the full dataset(s) available. A proper conclusion cannot be made without further testing.


== Question 2

*Question 2:* In which parts of your implementation have you used partitioning? Did this impact performance? If so,why?

// TODO: Add!
*TODO*


== Question 3

*Question 3*: Which datastructure(s) does your implementation use: RDDs, DataFrames, or Datasets? Please motivate your choice.

The implementation makes mostly use of the dataframes, since these, as seen in clase have the best performance optimization enabled under the hood. For reasoning on why RDD's were used in one specific section please see: @features.

== Question 4

*Question 4:*  Which predictive algorithm did you use and why?

The chosen predicate model is: `RandomForestRegressor`, since this is what was recommend in the FAQ section of the assignment.


= Benchmarks <benchmarks>

// TODO: Update benchmarks

// For all benchmarks, 4 runs were done. The first run was considered a dry run, while for the  proceeding 3, the average was taken.
//
// For the types of benchmarks ran on each host on the local context, both used the same provided dataset:
// - Type 1: No cache/persist & other default settings
// - Type 2: Cache & other default settings
// - Type 3: Persist & other default settings


== Specifications

=== Macbook

#table(
  columns: (1fr, 1fr),
  [*Part*], [*Value*],
  [CPU], [M2 Pro (6 performance and 4 efficiency)],
  [RAM], [16GB],
  [OS], [MacOS 15.7.2 (24G325)],
)


=== Desktop


#table(
  columns: (1fr, 1fr),
  [*Part*], [*Value*],
  [CPU], [Ryzen 9 5950X],
  [RAM], [64GB (3200Mhz)],
  [OS],
  [Windows Versie	10.0.22631 Build 22631
  ],
)

//
// == Results
//
// #let xs = (0, 1, 2)
// #let labels = ("None", "Cache", "Persist")
//
// #let macbook = (12, 21.33, 22.667)
// #let desktop = (16, 27, 26.67)
//
// #lq.diagram(
//   title: [Performance],
//   legend: (position: bottom + right),
//   xlabel: "Type",
//   ylabel: "Time (Seconds)",
//
//
//   xaxis: (ticks: xs.zip(labels)),
//
//   lq.plot(xs, macbook, mark: "s", label: [Macbook Pro]),
//   lq.plot(xs, desktop, mark: "s", label: [Desktop]),
// )
//
//



#set page(columns: 1)
= Appendix <appendix>


#figure(
  image(
    "images/BDP-Prediction-Legend.pdf"
),
  caption: [Prediction Step Flowchart Legend]
) <prediction-legend>


#bibliography("references.bib")
