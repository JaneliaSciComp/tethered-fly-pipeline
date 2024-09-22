FROM oraclelinux:9

ARG TARGETPLATFORM

LABEL org.opencontainers.image.licenses="BSD-3-Clause"

RUN yum install -y \
        wget unzip \
        libXt libXext libXmu libXrender libXcomposite

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# install Matlab-2019a
WORKDIR /mcr-install
RUN wget -q https://ssd.mathworks.com/supportfiles/downloads/R2023b/Release/9/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2023b_Update_9_glnxa64.zip
RUN unzip MATLAB_Runtime_R2023b_Update_9_glnxa64.zip
RUN ./install -mode silent -agreeToLicense yes
RUN rm -rf /mcr-install

# install the app
WORKDIR /app

ENV LD_LIBRARY_PATH=\
/usr/local/MATLAB/MATLAB_Runtime/R2023b/runtime/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/R2023b/bin/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/R2023b/sys/os/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/R2023b/sys/opengl/lib/glnxa64:\
/usr/local/MATLAB/MATLAB_Runtime/R2023b/sys/java/jre/glnxa64/jre/lib/amd64/server:\
/usr/local/MATLAB/MATLAB_Runtime/R2023b/sys/java/jre/glnxa64/jre/lib/amd64

COPY bin/compute3Dfrom2D_compiled.ol9-matlab2023b /app/bin/compute3Dfrom2D_compiled
COPY scripts/entrypoint.sh /app
RUN chmod +x /app/*.sh

CMD [ "/app/entrypoint.sh" ]
