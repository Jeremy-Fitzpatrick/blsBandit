# blsBandit R Package

The goal of this package is make it easy to view BLS data using Rshiny.
It is currently under development and only shows the U1-U6 unemployment data.

## Package Installation

If needed install devtools.
install.packages("devtools")
Install blsBandit.
devtools::install_github("Jeremy-Fitzpatrick/blsBandit")

## BLS Viewer

The blsViewer() function runs a simple GUI interface where the user can select
an employment series. Once the employment series is selected a start and end
date to be plotted in the interface can be selected.

## Update Unemployment Data

The updateUnemploymentData() function is used to update the unemployment data
series in the database. It is only necessary if you'd like to get the latest
data and will require the installation of the blsAPI package.

## Released Under MIT License
See LICENSE.md file.
