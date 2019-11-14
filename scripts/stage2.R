# --------------------------------------------------------------------------
# Stage 2
#
# Example usage: Rscript stage2.R --file 'results/stage_1_output.txt'
# --------------------------------------------------------------------------

option_list = list(
  optparse::make_option("--file",
                        default = 'results/stage_1_output.txt',
                        type = 'character',
                        help = "path to the input file")
)
opt = optparse::parse_args(optparse::OptionParser(option_list = option_list))

INPUT <- readLines(opt$file)
output <- paste("The input received by Stage 2 was:: ", INPUT)

dir.create("results")
writeLines(output, con = 'results/stage_2_output.txt')


