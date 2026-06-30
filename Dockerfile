# Imagem base oficial do n8n. Use o Dockerfile para fixar a versao e,
# se precisar, instalar pacotes/nodes extras no futuro.
FROM n8nio/n8n:2.28.3

# Timezone (passada via build arg, default Sao Paulo)
ARG TZ=America/Sao_Paulo
ENV TZ=${TZ} \
    GENERIC_TIMEZONE=${TZ}

# Porta interna padrao do n8n
EXPOSE 5678
