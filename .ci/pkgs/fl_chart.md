# fl_chart (fl_chart-1.2.0)

## CHANGELOG (ilk 150 satır)
```
## 1.2.0
* **BUGFIX** (by @imaNNeo) Consider the `enabled` property in [LineTouchData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#linetouchdata-read-about-touch-handling), [BarTouchData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md#bartouchdata-read-about-touch-handling), [PieTouchData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/pie_chart.md#pietouchdata-read-about-touch-handling), [ScatterTouchData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/scatter_chart.md#scattertouchdata-read-about-touch-handling), [RadarTouchData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/radar_chart.md#radartouchdata-read-about-touch-handling) and [CandlestickTouchData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/candlestick_chart.md#candlesticktouchdata-read-about-touch-handling), #1676
* **BUGFIX** (by @artshooter) Fix wrong bar chart color with small value, #1757
* **FEATURE** (by @3ph) Add `horizontalMirrored` and `verticalMirrored` properties in our `LabelDirection` enum which is used in ([HorizontalLineLabel](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/base_chart.md#HorizontalLineLabel) and [VerticalLineLabel](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/base_chart.md#VerticalLineLabel)), #1890
* **FEATURE** (by @Vizten18) Add `cornerRadius` property in the [PieChartSectionData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/pie_chart.md#piechartsectiondata), #1175
* **IMPROVEMENT** (by @imaNNeo) Add convention and linter (checker) for PRs title and updated contributing guideline. We're gonna have automated changelog generation from the next release
* **BUGFIX** (by @diymelvin) Fix inverted lowerBy/upperBy in error range calculation, #2031
* **FEATURE** (by @imaNNeo) Add `label` property in the [BarChartRodData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md#barchartroddata) to allow you to show a label on top of each bar rod, #2071, #84

## 1.1.1
* **IMPROVEMENT** (by @imaNNeo) Upgrade `vector_math` dependency to `2.2.0`, #1985
* **IMPROVEMENT** (by @imaNNeo) Upgrade `build_runner` (dev) dependency to `2.8.0`
* **IMPROVEMENT** (by @imaNNeo) Upgrade `mockito` (dev) dependency to `5.5.1`
* **IMPROVEMENT** (by @imaNNeo) Upgrade `very_good_analysis` (dev) dependency to `9.0.0`

## 1.1.0
* **FEATURE** (by @kamilJ96) Add `gradient` property inside our `BarChartRodStackItem` to be able to render gradient (along with the possibility to render a solid color), #919
* **FEATURE** (by @alettsy) Add `sideTitleAlignment` property in our `AxisTitles` to allow you to control the alignment of side titles (for example show them inside the chart), #1946
* **FEATURE** (by @huanghui1998hhh) Add `gradientArea` property to `LineChartBarData` to allow you to control the scope of gradient effects, #1925
* **FEATURE** (by @alikhavarii13) Add `label` and `labelStyle` properties in our `BarChartRodStackItem` to allow you to show labels on each stack item, #598
* **BREAKING** ⚠️ (by @alikhavarii13) `borderSide` now is a [named parameter](https://dart.dev/language/functions#named-parameters) (instead of a [optional positional parameter](https://dart.dev/language/functions#optional-positional-parameters) in `BarChartRodStackItem` constructor. As it is a very minor breaking change, we decided to include it in this minor release (instead of doing a major release based on the [semantic versioning](https://semver.org/). Sorry about that!
So you just need to change this:
```dart
BarChartRodStackItem(
  0,
  10,
  Colors.green,
  BorderSide(color: Colors.white),
),
```
to this:
```dart
BarChartRodStackItem(
  0,
  10,
  Colors.green,
  borderSide: BorderSide(color: Colors.white),
),
```

## 1.0.0
<img width="600" alt="Image" src="https://github.com/user-attachments/assets/3d8b58f4-4ce7-489f-ba45-27ece063f57c" />

* **FEATURE** (by @imaNNeo) Implement a new chart type called CandlestickChart. You can take a look at the documentation [here](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/candlestick_chart.md). And I just implemented a basic example to show the Bitcoin price in 2024, you can take a look at it in our sample app [here](https://app.flchart.dev/#/candlestick). #433, #1143
<img width="400" alt="Image" src="https://github.com/user-attachments/assets/f71b9e4f-3aa8-4688-a5c1-ffd8ff12fba1" />

* **BREAKING** (by @imaNNeo) Remove the deprecated `tooltipRoundedRadius` property -> you should use `tooltipBorderRadius` instead.
* **BUGFIX** (by @imaNNeo) Fix the BarChartData mismatch issue when changing the data, #1911
* **FEATURE** (by @frybitsinc) Add fillGradient property in [RadarDataSet](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/radar_chart.md#radardataset)
* **BREAKING** (by @imaNNeo) Upgrade the min flutter version to `3.27.4`. So please make sure that your project is not using an old flutter version, #1846
* **IMPORTANT** (by @imaNNeo) You can read more about this release and the history of fl_chart here in my [blog post](https://flutter4fun.com/fl-chart-1-0-0)

## 0.71.0
* **IMPROVEMENT** (by @MattiaPispisa) Add a new property called `BorderRadius tooltipBorderRadius` instead of (deprecated) `double tooltipRoundedRadius` in `BarTouchTooltipData`, `LineTouchTooltipData` and `ScatterTouchTooltipData` #1715
* **FEATURE** (by @frybitsinc) Add `children` property in our [RadarChartTitle](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/radar_chart.md#radarcharttitle), #1840
* **BUGFIX** (by @morvagergely) Fix the initial zoom issue in our scrollable LineChart, #1863

## 0.70.2
* **FEATURE** (by @imaNNeo) Add error range feature in our axis-based charts. You can set `xError` and `yError` in the [FlSpot](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/base_chart.md#flspot) or `toYErrorRange` in [BarChartRodData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md#barchartroddata). Also we have `errorIndicatorData` property in our [LineChartData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#linechartdata), [BarChartData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md#barchartdata) and [ScatterChartData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/scatter_chart.md#scatterchartdata) that is responsible to render the error bars. You can take a look at the [LineChartSample 13](https://github.com/imaNNeo/fl_chart/blob/main/example/lib/presentation/samples/line/line_chart_sample13.dart) and [BarChartSample 8](https://github.com/imaNNeo/fl_chart/blob/main/example/lib/presentation/samples/bar/bar_chart_sample8.dart) in our [sample app](https://app.flchart.dev), #1483 

## 0.70.1
* **FEATURE** (by @Peetee06) Add `panEnabled` and `scaleEnabled` properties in the TransformationController, #1818
* **FEATURE** (by @mitulagr2) Add `renderPriority` feature in our [ScatterSpot](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/scatter_chart.md#scatterspot), #1545
* **FEATURE** (by @imaNNeo) Add `rotationQuarterTurns` property in our Axis-Based charts (such as [LineChart](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md), [BarChart](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md) and [ScatterChart](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/scatter_chart.md)). It allows you to rotate the chart 90 degrees (clockwise) in each turn. For example you can have Horizontal Bar Charts by setting `rotationQuarterTurns` to 1 (which rotates the chart 90 degrees clockwise). It works exactly like [RotatesBox](https://api.flutter.dev/flutter/widgets/RotatedBox-class.html) widget, #113
* **FEATURE** (by @soraef) Add `isMinValueAtCenter` property in the [RadarChart](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/radar_chart.md) to allow the user to set the minimum value at the center of the chart, #1351, #1442
* **BREAKING** (by @imaNNeo) Add `TitleMeta` parameter in the `SideTitleWidget` instead of `axisSide`

## 0.70.0
* **FEATURE** (by @Peetee06) Implemented a 5 years-old feature request about scroll and zoom support in our axis-based charts. Special thanks to @Peetee06 who made it happen, #71
* **IMPROVEMENT** (by @Peetee06) Added functionality to control the transformation of axis-based charts using `FlTransformationConfig` class. You can now enable scaling and panning for `LineChart`, `BarChart` and `ScatterChart` using this class
* **IMPROVEMENT** (by @Peetee06) Added some new unit tests in `bar_chart_data_extensions_test.dart`, `gradient_extension_test.dart` and fixed a typo in `bar_chart_data.dart`
* **BREAKING** (by @Peetee06) Fixed the equatable functionality in our BarChart. We hope it will not affect anything in our chart, but because the behaviour is changed, we marked it as a breaking change. (read more [here](https://github.com/imaNNeo/fl_chart/pull/1789#discussion_r1858371718))
* **BREAKING** (by @Peetee06) `BarChart` is not const anymore due to adding an assert to check if transformations are allowed depending on the `BarChartData.alignment` property (read more [here](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/migration_guides/0.70.0/MIGRATION_00_70_00.md))
* **IMPROVEMENT** (by @Peetee06) Upgrade to the new Flutter version ([3.27.0](https://medium.com/flutter/whats-new-in-flutter-3-27-28341129570c)), #1804
* **IMPROVEMENT** (by @AliAkberAakash) Minor typo fix in our line chart documentation, #1795
* **IMPROVEMENT** (by @imaNNeo) Fixed the code coverage API rate-limit issue
* **Improvement** (by @imaNNeo) Published the example app in Google Play and App Store. Other stores (such as [snap store](https://snapcraft.io/store) and [Microsoft Store](https://apps.microsoft.com/home)) will come next. You can download the Android version here in [Google Play](https://play.google.com/store/apps/details?id=dev.flchart.app) and the iOS version here in [App Store](https://apps.apple.com/us/app/fl-chart/id6476523019)

## 0.69.2
* **IMPROVEMENT** (by @imaNNeo) Fix the analyzer warnings (to have maximum score in the [pub.dev](https://pub.dev/packages/fl_chart/score))

## 0.69.1
* **IMPROVEMENT** (by @moshe5745) Update the docs related to line chart's `duration` and `curve` properties, #1618
* **IMPROVEMENT** (by @imaNNeo) Deprecate `swapAnimationDuration` and `swapAnimationCurve` properties to use `curve` and `duration` instead to keep the consistency over the project, #1618
* **BUGFIX** (by @aimawari) Fixed lots of issues related to the zero value in the PieChartSectionData, #697, #817 and #1632

## 0.69.0
* **BUGFIX** (by @imaNNeo) Fix a memory leak issue in the axis-based charts, there was a logic to calculate and cache the minX, maxX, minY and maxY properties to reduce the computation cost. But it caused some memory issues, as we don't have a quick solution for this, we disabled the caching logic for now, later we can move the calculation logic to the render objects to keep and update them only when the data is changed, #1106, #1693
* **BUGFIX**  (by @imaNNeo) Fix showing grid lines even when there is no line to show in the LineChart, #1691
* **IMPROVEMENT** (by @sczesla) Allow users to control minIncluded and maxIncluded using SideTitles, #906
* **IMPROVEMENT** (by @elizabethzhenliu) Reverse the touch order in ScatterChart, so now the top spots are touched first, #1675
* **IMPROVEMENT** (by @ksw2000) Remove redundant math import, #1683
* **IMPROVEMENT** (by @Neer-Pathak) Fix linux example build issue, #1668
* **IMPROVEMENT** (by @TobiasRump) Update the bar chart documentation, #1662

## 0.68.0
* **Improvement** (by @imaNNeo) Update LineChartSample6 to implement a way to show a tooltip on a single spot, #1620
* **Feature** (by @herna) Add `titleSunbeamLayout` inside the [BarChartData](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md#barchartdata) to allow the user to customize the layout of the title sunbeam
* **Improvement** (by @imaNNeo) Add LineChart and BarChart explanation videos on top of the respective documentation pages ([LineChart video](https://youtu.be/F3wTxTdAFaU?si=8lwlypKjt-0aJJK0), [BarChart video](https://youtu.be/vYe0RY1nCAA?si=30q_7eNn9MDLcph4))

## 0.67.0
* **FEATURE** (by @julien4215) Add direction property to the [HorizontalLineLabel](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/base_chart.md#horizontallinelabel) and [VerticalLineLabel](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/base_chart.md#verticallinelabel), #1574
* **FEATURE**  (by @apekshamehta) Added new method called getTooltipColor for axis charts (bar,line,scatter) to change background color of tooltip dynamically, #1279.
* **BREAKING** (by @apekshamehta) Removed tooltipBgColor property from Bar, Line and Scatter Charts (you can now use `getTooltipColor` which provides more customizability), checkout the [full migration guide here](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/migration_guides/0.67.0/MIGRATION_00_67_00.md).
```dart
/// Migration guide:
/// This is the old way:
BarChartData(
  barTouchData: BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      tooltipBgColor: Colors.blueGrey,
    )
  )
)

/// This is the new way:
BarChartData(
  barTouchData: BarTouchData(
    touchTooltipData: BarTouchTooltipData(
      getTooltipColor: (BarChartGroupData group) => Colors.blueGrey,
    )
  )
)
```

## 0.66.2
* **BUGFIX** (by @stwarwas) Remove dart.io to fix web platform issue, #1577

## 0.66.1
* **BUGFIX** (by @imaNNeo) Fix PieChart blackout issue, #1538
* **BUGFIX** (by @imaNNeo) Fix memory leak in LineChart and BarChart, #1106

## 0.66.0
* **IMPROVEMENT** (by @imaNNeo) Add Flutter sdk constraints to the pubspec.yaml to force the user/developer to upgrade the Flutter version to 3.16.0 (latest), #1509
* **IMPROVEMENT** (by @imaNNeo) Add `dotPainter` property to ScatterSpot to allow customizing the dot painter, #568
* **BREAKING** (by @imaNNeo) Remove `color` and `radius` properties from ScatterSpot (use `dotPainter` instead), #568
* **BREAKING** (by @imaNNeo) Change the default value of FlDotCirclePainter.`strokeWidth` to 0.0
```dart
/// Migration guide:
/// This is the old way:
ScatterSpot(
  2,
  5,
  color: Colors.red,
  radius: 12,
)

/// This is the new way:
ScatterSpot(
  2,
```

## README (ilk 200 satır)
```
![FL Chart Logo](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/landing_logo.png)

[![pub package](https://img.shields.io/pub/v/fl_chart.svg)](https://pub.dartlang.org/packages/fl_chart)
[![codecov](https://codecov.io/gh/imaNNeo/fl_chart/branch/main/graph/badge.svg?token=XBhsIZBbZG)](https://codecov.io/gh/imaNNeo/fl_chart)
<a href="https://github.com/Solido/awesome-flutter#charts"><img src="https://img.shields.io/badge/awesome-flutter-blue.svg?longCache=true" alt="Awesome Flutter"></a>
<a href="https://pub.dev/packages/fl_chart"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/imaNNeo/fl_chart"></a>
<a href="https://github.com/imaNNeo/fl_chart/graphs/contributors"><img alt="GitHub contributors" src="https://img.shields.io/github/contributors/imaNNeo/fl_chart"></a>
<a href="https://githubc.com/imaNNeo/fl_chart/issues?q=is%3Aissue+is%3Aclosed"><img src="https://img.shields.io/github/issues-closed-raw/imaNNeo/fl_chart" alt="GitHub closed issues"></a>
![GitHub Sponsors](https://img.shields.io/github/sponsors/imaNNeo) 
<span class="badge-buymeacoffee">
<a href="https://www.buymeacoffee.com/fl_chart" title="Donate to this project using Buy Me A Coffee"><img src="https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg" alt="Buy Me A Coffee donate button" /></a>
</span>

### Our Financial Heroes
Your financial support acts as fuel for fl_chart's development. [Support here](https://github.com/sponsors/imaNNeo).
<table>
	<tbody>
		<tr>
				<td>
					<a href="https://github.com/sponsors/imaNNeo">
						<img src="https://github.com/imaNNeo/fl_chart_landing/raw/main/static/img/sponsors/intero-the-sniffers.png">
					</a>
				</td>
				<td>
					<a href="https://github.com/sponsors/imaNNeo">
						<picture>
							<source media="(prefers-color-scheme: dark)" srcset="https://github.com/imaNNeo/fl_chart/raw/main/repo_files/sponsors/become_a_sponsor_dark.png">
							<source media="(prefers-color-scheme: light)" srcset="https://github.com/imaNNeo/fl_chart/raw/main/repo_files/sponsors/become_a_sponsor_light.png">
							<img alt="Become a sponsor" >
						</picture>
					</a>
				</td>
				<td>
					<a href="https://github.com/sponsors/imaNNeo">
						<img src="https://github.com/imaNNeo/fl_chart/raw/main/repo_files/sponsors/become_a_hero_empty.png">
					</a>
				</td>
				<td>
					<a href="https://github.com/sponsors/imaNNeo">
						<img src="https://github.com/imaNNeo/fl_chart/raw/main/repo_files/sponsors/become_a_hero_empty.png">
					</a>
				</td>
		</tr>
	</tbody>
</table>

### Overview
FL Chart is a highly customizable Flutter chart library that supports **[Line Chart](https://app.flchart.dev/#/line)**, **[Bar Chart](https://app.flchart.dev/#/bar)**, **[Pie Chart](https://app.flchart.dev/#/pie)**, **[Scatter Chart](https://app.flchart.dev/#/scatter)**, and **[Radar Chart](https://app.flchart.dev/#/radar)**.

<a href="https://www.youtube.com/watch?v=hVRU-kpKNjQ&list=PL1-_rCwRcnbNpvodmbt43O81wMUdBv8-a"><img src="https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/overview_thumbnail.png"></p></a>


### Chart Types

|LineChart	|BarChart		|PieChart		|
|:------------:|:------------:|:-------------:|
|	[![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/line_chart/line_chart_sample_1.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#sample-1-source-code) [![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/line_chart/line_chart_sample_2.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#sample-2-source-code)  |	[![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/bar_chart/bar_chart_sample_1.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md#sample-1-source-code) [![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/bar_chart/bar_chart_sample_2.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md#sample-2-source-code)  | [![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/pie_chart/pie_chart_sample_1.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/pie_chart.md#sample-1-source-code) [![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/pie_chart/pie_chart_sample_2.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/pie_chart.md#sample-2-source-code) |
|[Read More](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md)|[Read More](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md)|[Read More](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/pie_chart.md)|

|ScatterChart	|RadarChart| CandlestickChart|
|:------------:|:------------:|:-------------:|
|	[![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/scatter_chart/scatter_chart_sample_1.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/scatter_chart.md#sample-1-source-code) [![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/scatter_chart/scatter_chart_sample_2.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/scatter_chart.md#sample-2-source-code)  |	![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/radar_chart/radar_chart_sample_1.jpg)  ![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/blank.png)|![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/candlestick_chart/candlestick_chart_sample_1.gif) ![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/blank.png)|
|[Read More](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/scatter_chart.md)|[Read More](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/radar_chart.md)|[Read More](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/candlestick_chart.md)|

Banner designed by [Soheil Saffar](https://www.linkedin.com/in/soheilsaffar), and
samples inspired from
[David Kovalev](https://dribbble.com/shots/5560237-Live-Graphs-XD),
[Ricardo Salazar](https://dribbble.com/shots/1956890-Data-Stats),
[Dmitro Petrenko](https://dribbble.com/shots/5425378-Mobile-Application-Dashboard-for-Stock-Platform),
[Ghani Pradita](https://dribbble.com/shots/6379476-Calories-Management-App),
[MONUiXD](https://www.uplabs.com/posts/chart-pie-chart-bar-chart).
Thank you all!



# Let's get started

First of all, you need to add the `fl_chart` in your project. To do that, follow [this guide](https://pub.dev/packages/fl_chart/install).

Then you need to read the docs. Start from [here](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/index.md).

We suggest that you check the sample source code.

##### - You can read about the animation handling [here](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/handle_animations.md)
|Sample1	|Sample2		|Sample3		|
|:------------:|:------------:|:-------------:|
|	[![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/line_chart/line_chart_sample_1_anim.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#sample-1-source-code)   |	[![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/line_chart/line_chart_sample_2_anim.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#sample-2-source-code) | [![](https://github.com/imaNNeo/fl_chart/raw/main/repo_files/images/bar_chart/bar_chart_sample_1_anim.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/bar_chart.md#sample-1-source-code) |

### Try it out
You can try the FL Chart sample app on the platforms that are available below:

[![Get it on Google Play](https://img.shields.io/badge/Get%20it%20on-Google%20Play-green?style=for-the-badge&logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=dev.flchart.app)
[![Download on the App Store](https://img.shields.io/badge/Download-on%20the%20App%20Store-blue?style=for-the-badge&logo=app-store&logoColor=white)](https://apps.apple.com/us/app/fl-chart/id6476523019)
[![Try it on Web](https://img.shields.io/badge/Try%20it%20on-Web-yellow?style=for-the-badge&logo=google-chrome&logoColor=white)](https://app.flchart.dev)

[//]: # ([![Download for macOS]&#40;https://img.shields.io/badge/Download-for%20macOS-darkblue?style=for-the-badge&logo=apple&logoColor=white&#41;]&#40;https://apps.apple.com/app/your-macos-app-id&#41;)
[//]: # ([![Download for Linux]&#40;https://img.shields.io/badge/Download-for%20Linux-orange?style=for-the-badge&logo=linux&logoColor=white&#41;]&#40;https://your-linux-distribution-link.com&#41;)
[//]: # ([![Download for Windows]&#40;https://img.shields.io/badge/Download-for%20Windows-blue?style=for-the-badge&logo=windows&logoColor=white&#41;]&#40;https://your-windows-app-link.com&#41;)


### Donation
Your donation motivates me to work more on the fl_chart and resolve more issues.
There are multiple ways to donate to me:

1. You can be my sponsor on [GitHub](https://github.com/sponsors/imaNNeo) (This is the most reliable way to donate to me)
2. You can <a href="https://www.buymeacoffee.com/fl_chart">buy me a coffee!</a>
3. Or if you are a fan of crypto, you can donate me Bitcoins here: `1L7ghKdcmgydmUJAnmYmMaiVjT1LoP4a45`

### Contributing
##### :beer: Pull requests are welcome!
Remember that open-source projects thrive on contributions. Every improvement—no matter how small—makes a meaningful difference, even if it’s just a single line.

Our documentation may contain grammatical issues, and if you’re fluent in English, your help in correcting them would be greatly appreciated.

Check out [CONTRIBUTING.md](https://github.com/imaNNeo/fl_chart/blob/main/CONTRIBUTING.md), which contains a guide for those who want to contribute to the FL Chart.

Reporting bugs and issues is also a contribution, yes, it is.

#### Below are the people who have contributed to the FL Chart. We hope we have your picture here soon.
[![](https://opencollective.com/fl_chart/contributors.svg?width=890&button=false)](https://github.com/imaNNeo/fl_chart/graphs/contributors)
```
