from typing import Optional, Protocol, Union


class AWSLambdaClientContextMobileClient(Protocol):
    installation_id: str
    app_package_name: str
    app_title: str
    app_version_code: str
    app_version_name: str


class AWSLambdaClientContext(Protocol):
    client: AWSLambdaClientContextMobileClient
    custom: dict
    env: dict


class AWSLambdaCognitoIdentity(Protocol):
    cognito_identity_id: str
    cognito_identity_pool_id: str


class AWSLambdaContext(Protocol):
    """[Typing protocol][tp] for [AWS Lambda contexts in Python][pc].
    ---

    [tp]: https://mypy.readthedocs.io/en/stable/protocols.html
    [pc]: https://docs.aws.amazon.com/lambda/latest/dg/python-context.html
    """

    function_name: str
    function_version: str
    invoked_function_arn: str
    memory_limit_in_mb: int
    aws_request_id: str
    log_group_name: str
    log_stream_name: str
    identity: AWSLambdaCognitoIdentity
    client_context: AWSLambdaClientContext

    @staticmethod
    def get_remaining_time_in_millis() -> int:
        ...


# https://docs.aws.amazon.com/lambda/latest/dg/python-handler.html
AWSLambdaEventType = Optional[Union[dict, list, str, int, float]]
