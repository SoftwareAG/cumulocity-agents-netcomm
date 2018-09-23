#!/bin/bash -x

INPUT_FILE=$1
OUTPUT_FILE="auto_provisioning_env.json"

cp ${INPUT_FILE} ${OUTPUT_FILE}

if [ ! -z ${CUMULOCITY_KUBERNETES_IMAGE} ]; then
    cat ${OUTPUT_FILE} | \
    jq '.override_attributes["cumulocity-kubernetes"]["images-version"] = env.CUMULOCITY_KUBERNETES_IMAGE' > ${OUTPUT_FILE}'.tmp';
    mv ${OUTPUT_FILE}'.tmp' ${OUTPUT_FILE};
    echo ${CUMULOCITY_KUBERNETES_IMAGE}
fi

if [ ! -z ${CUMULOCITY_KARAF_IMAGE} ]; then
    cat ${OUTPUT_FILE} | \
    jq '.override_attributes["cumulocity-karaf"]["version"] = env.CUMULOCITY_KARAF_IMAGE' > ${OUTPUT_FILE}'.tmp';
    mv ${OUTPUT_FILE}'.tmp' ${OUTPUT_FILE};
fi

if [ ! -z ${CUMULOCITY_KARAF_SSA} ]; then
    cat ${OUTPUT_FILE} | \
    jq '.override_attributes["cumulocity-karaf"]["ssa-version"] = env.CUMULOCITY_KARAF_SSA' > ${OUTPUT_FILE}'.tmp';
    mv ${OUTPUT_FILE}'.tmp' ${OUTPUT_FILE};
fi

if [ ! -z ${CUMULOCITY_GUI} ]; then
    cat ${OUTPUT_FILE} | \
    jq '.override_attributes["cumulocity-GUI"]["version"] = env.CUMULOCITY_GUI' > ${OUTPUT_FILE}'.tmp';
    mv ${OUTPUT_FILE}'.tmp' ${OUTPUT_FILE};
fi
