% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vr_render_tableone.R
\name{vr_render_tableone}
\alias{vr_render_tableone}
\title{Render Summary Table}
\usage{
vr_render_tableone(table1_df, caption, output_format = "html", engine = "gt")
}
\arguments{
\item{table1_df}{The summary table of a dataset created by \code{vr_create_tableone}}

\item{caption}{Table caption to include in the rendered table}

\item{output_format}{If TRUE, the summary statistics for the overall dataset are also calculated}

\item{engine}{If html is selected as output format, one can chose between using kable, gt and DT as engine to create the output table}
}
\description{
Render a previously created summary table

Create formatted table
}
