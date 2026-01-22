# common
FROM ubuntu:22.04 AS common
RUN apt update
CMD ["sh", "-c", "echo Myname is $my_name"]

# unique
FROM common AS development
ENV my_name=dev

FROM common AS production
ENV my_name=prod