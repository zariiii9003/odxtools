# SPDX-License-Identifier: MIT
from dataclasses import dataclass
from typing import Literal, Optional

from typing_extensions import override

from .decodestate import DecodeState
from .diagcodedtype import DctType, DiagCodedType
from .encodestate import EncodeState
from .exceptions import odxassert, odxraise, odxrequire
from .odxtypes import AtomicOdxType, DataType


@dataclass
class StandardLengthType(DiagCodedType):

    bit_length: int
    bit_mask: Optional[int]
    is_condensed_raw: Optional[bool]

    @property
    def dct_type(self) -> DctType:
        return "STANDARD-LENGTH-TYPE"

    @property
    def is_condensed(self) -> bool:
        return self.is_condensed_raw is True

    def __post_init__(self) -> None:
        if self.bit_mask is not None:
            maskable_types = (DataType.A_UINT32, DataType.A_INT32, DataType.A_BYTEFIELD)
            odxassert(
                self.base_data_type in maskable_types,
                'Can not apply a bit_mask on a value of type {self.base_data_type}',
            )

    def __get_raw_mask(self, internal_value: AtomicOdxType) -> Optional[bytes]:
        """Returns a byte field where all bits that are used by the
        DiagCoded type are set and all unused ones are not set.

        If `None` is returned, all bits are used.
        """
        if self.bit_mask is None:
            return None

        if self.is_condensed:
            odxraise("Condensed bit masks are not yet supported", NotImplementedError)
            return

        endianness: Literal["little", "big"] = "big"
        if not self.is_highlow_byte_order and self.base_data_type in [
                DataType.A_INT32, DataType.A_UINT32, DataType.A_FLOAT32, DataType.A_FLOAT64
        ]:
            # TODO (?): Technically, little endian A_UNICODE2STRING
            # objects require a byte swap for each 16 bit letter, and
            # thus also for the mask. I somehow doubt that this has
            # been anticipated by the standard, though...
            endianness = "little"

        sz: int
        if isinstance(internal_value, (bytes, bytearray)):
            sz = len(internal_value)
        else:
            sz = (odxrequire(self.get_static_bit_length()) + 7) // 8

        return self.bit_mask.to_bytes(sz, endianness)

    def __apply_mask(self, internal_value: AtomicOdxType) -> AtomicOdxType:
        if self.bit_mask is None:
            return internal_value
        if self.is_condensed:
            odxraise("Serialization of condensed bit mask is not supported", NotImplementedError)
            return
        if isinstance(internal_value, int):
            return internal_value & self.bit_mask
        if isinstance(internal_value, bytes):
            int_value = int.from_bytes(internal_value, 'big')
            int_value = int_value & self.bit_mask
            return int_value.to_bytes(len(internal_value), 'big')

        odxraise(f'Can not apply a bit_mask on a value of type {type(internal_value)}')
        return internal_value

    def get_static_bit_length(self) -> Optional[int]:
        return self.bit_length

    @override
    def encode_into_pdu(self, internal_value: AtomicOdxType, encode_state: EncodeState) -> None:
        encode_state.emplace_atomic_value(
            internal_value=self.__apply_mask(internal_value),
            used_mask=self.__get_raw_mask(internal_value),
            bit_length=self.bit_length,
            base_data_type=self.base_data_type,
            is_highlow_byte_order=self.is_highlow_byte_order)

    @override
    def decode_from_pdu(self, decode_state: DecodeState) -> AtomicOdxType:
        internal_value = decode_state.extract_atomic_value(
            self.bit_length,
            self.base_data_type,
            self.is_highlow_byte_order,
        )
        internal_value = self.__apply_mask(internal_value)

        return internal_value
