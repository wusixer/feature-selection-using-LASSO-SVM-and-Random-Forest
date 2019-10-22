
var_file=$1
weight_file=$2


fn_name=`ls $var_file|cut -d'.' -f1-2 `
cat $var_file|tr ' ' '\n'| awk 'NF' >$var_file.1
cat $weight_file|tr ' ' '\n'|awk 'NF'>$weight_file.1

paste -d' ' $var_file.1 $weight_file.1 >best.$fn_name

#rm aa*best*
#rm ea*best*
