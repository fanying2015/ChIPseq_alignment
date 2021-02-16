BWA=~/software/bwa-0.7.17/bwa
SAMTOOLS=~/software/samtools-0.1.18/samtools
TRIM=~/software/trim_galore_zip/trim_galore
FASTQC=~/anaconda2/bin/fastqc

GENOME=~/project/genomes/bwa/hg19/hg19.fa

BASEDIR=${1}
FASTQLOC=${BASEDIR}/fastq/
FASTQCLOC=${BASEDIR}/fastqc/
ALIGNLOC=${BASEDIR}/bam/
CPU=20

cd ${FASTQLOC}
sampleList=`ls *fastq.gz* | cut -d . -f 1`
for sample in $sampleList
do
    name=${sample}
    echo ${name}
    gunzip ${name}.fastq.gz
    ${FASTQC} -o ${FASTQCLOC} -f fastq ${FASTQLOC}/${name}.fastq
    ${TRIM} --output_dir ${FASTQLOC} ${FASTQLOC}/${name}.fastq
    ${FASTQC} -o ${FASTQCLOC} -f fastq ${FASTQLOC}/${name}_trimmed.fq
    mv ${name}.fastq_trimming_report.txt ${BASEDIR}/report/
    ${BWA} mem -t ${CPU} ${GENOME} ${FASTQLOC}/${name}_trimmed.fq  > ${ALIGNLOC}/${name}.sam
    $SAMTOOLS view -bS ${ALIGNLOC}/${name}.sam > ${ALIGNLOC}/${name}.fastq.gz.bam
    rm ${ALIGNLOC}/${name}.sam
    samtools sort ${ALIGNLOC}/${name}.fastq.gz.bam ${ALIGNLOC}/${name}.fastq.gz.sorted
    samtools index ${ALIGNLOC}/${name}.fastq.gz.sorted.bam
    rm ${ALIGNLOC}/${name}.fastq.gz.bam
    rm ${name}_trimmed.fq
    gzip ${name}.fastq
done
