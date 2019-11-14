# --------------------------------------------------------------------------
# Stage 1
#
# Example usage: Rscript stage1.R
# --------------------------------------------------------------------------

option_list = list(
  optparse::make_option("--input",
                        default = "this is the default string",
                        type = 'character',
                        help = "input text")
)
opt = optparse::parse_args(optparse::OptionParser(option_list = option_list))

INPUT <- opt$input
output <- paste("Stage 1 simply passes along this string: ", INPUT)

dir.create("results")
writeLines(output, con = 'results/stage_1_output.txt')
