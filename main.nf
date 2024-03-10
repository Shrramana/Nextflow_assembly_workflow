#!/bin/bash

//params.input1 = "$baseDir/SRR26244988_1.fastq"
//params.input2 = "$baseDir/SRR26244988_2.fastq"


//Getting input file from the command line
params.input1 = file(args[0])
params.input2 = file(args[1])

//Setting path for output dir
params.outdir = "$baseDir"

//process for trimming
//input passed in from cmd

process trimFastQ {
publishDir("${params.outdir}", mode: 'copy')

//Setting input
input: 
file input1
file input2


//Setting output
output: 
path "ptrimmed1.fq.gz", emit: out1
path "uptrimmed1.fq.gz"
path "ptrimmed2.fq.gz", emit: out2    
path "uptrimmed2.fq.gz"

//trimmomatic command for trimming
script: 
""" 
trimmomatic PE -phred33 $input1 $input2 ptrimmed1.fq.gz uptrimmed1.fq.gz ptrimmed2.fq.gz uptrimmed2.fq.gz MAXINFO:28:0.8 1> trimmo.stdout.log 2> trimmo.stderr.log
""" 
}

//process for assembly using spades
//input from trimFastQ process

process assembleSPAdes { 
publishDir("${params.outdir}", mode: 'copy')

//Setting input
input:
file trim1
file trim2


//Setting output
output: 
path "*"

//Spades command for assembly
script: 
""" 
spades.py -1 ${trim1} -2 ${trim2} -o assembly 
""" 
} 



// Workflow to instruct on process sequence and setting channels for input 
workflow { 
inp1_ch = Channel.fromPath(params.input1)
inp2_ch = Channel.fromPath(params.input2)


//Initiating trimFastQ process
trimFastQ(inp1_ch,inp2_ch)


//Initiating assembleSPAdes process
assembleSPAdes(trimFastQ.out.out1, trimFastQ.out.out2)
 
} 
