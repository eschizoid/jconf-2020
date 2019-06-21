const AWS = require('aws-sdk');
const dotenv = require('dotenv');
const bucketName = 's3://chicago-cloud-conference-2019/gold/*/*/';

dotenv.config();

const s3Client = new AWS.S3({
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_ACCESS_KEY_SECRET,
});

s3Client
    .selectObjectContent({
        Bucket: bucketName,
        Key: 'part-*.parquet',
        ExpressionType: 'Parquet',
        Expression: 'SELECT s.* FROM S3Object[*][*] s WHERE s.location',
        InputSerialization: {
            CompressionType: 'SNAPPY',
        },
        OutputSerialization: {
            Parquet: {}
        }
    })
    .promise()
    .then(output => {
        output.Payload.on('data', event => {
            if (event.Records) {
                // THIS IS OUR RESULT
                let buffer = event.Records.Payload;
                console.log(buffer.toString());
            }
        });
    })
    .then(err => {
        console.error(err);
    });
