FROM ubuntu:22.04

# ARG message_arg="message arg"
# ENV message_env="message env"

# RUN echo $message_arg > message_arg.txt
# RUN echo $message_env > message_env.txt

RUN touch 1.txt
WORKDIR /app/my_dir

RUN touch 2.txt
WORKDIR ..

RUN touch 3.txt

CMD ["bash"]