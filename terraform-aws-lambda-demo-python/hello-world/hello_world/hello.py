import json

from hello_world._types import AWSLambdaContext, AWSLambdaEventType


def lambda_handler(event: AWSLambdaEventType, context: AWSLambdaContext) -> dict:
    """AWS Lambda function handler Python example
    ---

    This is an example AWS Lambda function handler written in Python.
    The default name is `lambda_handler`, but any function name can be used.

    Lambda function handlers should accept `event` and `context` as arguments.

    Return types will vary depending on the purpose of the function handler. Here, the
    handler returns a dict with `statusCode`, `headers`, and `body` for API Gateway.

    See the [AWS Lambda concepts docs][lc] and [AWS Lambda Python handler docs][ph].

    [ph]: https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
    [lc]: https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-concepts.html
    """
    print(f"Received event: {json.dumps(event)}")
    print(f"Lambda function ARN: {context.invoked_function_arn}")
    print(f"CloudWatch log stream name: {context.log_stream_name}")
    print(f"CloudWatch log group name: {context.log_group_name}")
    print(f"Lambda Request ID: {context.aws_request_id}")
    print(f"Lambda function memory limits in MB: {context.memory_limit_in_mb}")
    name_from_query_parameters = (
        query_parameters.get("name") or query_parameters.get("Name")
        if isinstance(event, dict)
        and (query_parameters := event.get("queryStringParameters"))
        else None
    )
    response_body = {
        "message": f"Hello, {name_from_query_parameters or 'World'}!",
        "details": "Python Lambda function example",
    }
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": str(response_body),
    }
